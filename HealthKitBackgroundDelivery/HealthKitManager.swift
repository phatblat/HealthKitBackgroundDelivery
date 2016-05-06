//
//  HealthKitManager.swift
//  HealthKitBackgroundDelivery
//
//  Created by Ben Chatelain on 5/5/16.
//  Copyright © 2016 Ben Chatelain. All rights reserved.
//

import HealthKit

typealias AccessRequestCallback = (success: Bool, error: NSError?) -> Void

/// Helper for reading and writing to HealthKit.
class HealthKitManager {
    private let healthStore = HKHealthStore()

    /// Requests access to all the data types the app wishes to read/write from HealthKit.
    /// On success, data is queried immediately and observer queries are set up for background
    /// delivery. This is safe to call repeatedly and should be called at least once per launch.
    func requestAccessWithCompletion(completion: AccessRequestCallback) {
        guard deviceSupportsHealthKit() else {
            debugPrint("HealthKit is not supported on this device. (or tests are running)")
            return
        }

        let writeDataTypes = dataTypesToWrite()
        let readDataTypes = dataTypesToRead()

        healthStore.requestAuthorizationToShareTypes(writeDataTypes, readTypes: readDataTypes) { [weak self] (success: Bool, error: NSError?) in
            guard let strongSelf = self else { return }
            if success {
                debugPrint("Access to HealthKit data has been granted")
                strongSelf.readHealthKitData()
                strongSelf.setUpBackgroundDeliveryForDataTypes(readDataTypes)
            } else {
                debugPrint("Error requesting HealthKit authorization: \(error)")
            }

            dispatch_async(dispatch_get_main_queue()) {
                completion(success: success, error: error)
            }
        }
    }
}

// MARK: - Private
private extension HealthKitManager {
    /// Determines whether the device supports HealthKit. HealthKit is not supported while running unit tests (XCTestCase)
    ///
    /// - returns: true if device and current OS support HealthKit; false otherwise.
    private func deviceSupportsHealthKit() -> Bool {
        return HKHealthStore.isHealthDataAvailable() && NSClassFromString("XCTestCase") == nil
    }

    /// Initiates an `HKAnchoredObjectQuery` for each type of data that the app reads and stores
    /// the result as well as the new anchor.
    private func readHealthKitData() {
        for type in dataTypesToRead() {
            readHealthKitData(type)
        }
    }

    /// Sets up the observer queries for background health data delivery.
    ///
    /// - parameter types: Set of `HKSampleType` to observe changes to.
    private func setUpBackgroundDeliveryForDataTypes(types: Set<HKSampleType>) {
        for type in types {
            let query = HKObserverQuery(sampleType: type, predicate: nil) { [weak self] (query: HKObserverQuery, completionHandler: HKObserverQueryCompletionHandler, error: NSError?) in
                debugPrint("observer query update handler called for type \(type), error: \(error)")
                guard let strongSelf = self else { return }
                strongSelf.queryForUpdates(type)
                completionHandler()
            }
            healthStore.executeQuery(query)
            healthStore.enableBackgroundDeliveryForType(type, frequency: .Immediate) { (success: Bool, error: NSError?) in
                debugPrint("enableBackgroundDeliveryForType handler called for \(type) - success: \(success), error: \(error)")
            }
        }
    }

    /// Initiates HK queries for new data based on the given type
    ///
    /// - parameter type: `HKObjectType` which has new data avilable.
    private func queryForUpdates(type: HKObjectType) {
        switch type {
        case HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!:
            debugPrint("HKQuantityTypeIdentifierBodyMass")
        case HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)!:
            debugPrint("HKQuantityTypeIdentifierHeight")
        case is HKWorkoutType:
            debugPrint("HKWorkoutType")
        default: debugPrint("Unhandled HKObjectType: \(type)")
        }
    }

    /// Types of data that this app wishes to read from HealthKit.
    ///
    /// - returns: A set of HKSampleType.
    private func dataTypesToRead() -> Set<HKSampleType> {
        return Set(arrayLiteral:
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)!,
            HKObjectType.workoutType()
        )
    }
    
    /// Types of data that this app wishes to write to HealthKit.
    ///
    /// - returns: A set of HKSampleType.
    private func dataTypesToWrite() -> Set<HKSampleType> {
        return Set(arrayLiteral:
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)!,
            HKObjectType.workoutType()
        )
    }
}

// MARK: - Queries
private extension HealthKitManager {
    private func readHealthKitData(type: HKSampleType) {
        let typeName = type.typeName
        let anchorKey = typeName + "QueryAnchor"
        let anchor = NSUserDefaults.standardUserDefaults().integerForKey(anchorKey)

        // Deprecated iOS 8 API
        // Specifying no limit because otherwise we only get the oldest record
        let query = HKAnchoredObjectQuery(type: type, predicate: nil, anchor: anchor, limit: Int(HKObjectQueryNoLimit)) {
            (query: HKAnchoredObjectQuery, samples: [HKSample]?, newAnchor: Int, error: NSError?) in

            guard let samples = samples as? [HKQuantitySample] else {
                debugPrint("Unable to query HealthKit for \(typeName) sample: \(error?.localizedDescription)")
                return
            }

            guard samples.count > 0, let _ = samples.last else {
                debugPrint("HealthKit \(typeName) query successful, but returned empty results")
                return
            }

            NSUserDefaults.standardUserDefaults().setInteger(newAnchor, forKey: anchorKey)

//            let value = sample.quantity.doubleValueForUnit(heightUnit.hkunit)
//            debugPrint("Sample retrieved from HealthKit: \(value), \(heightUnitString) (source: \(sample.source))")
        }

        healthStore.executeQuery(query)
    }
}