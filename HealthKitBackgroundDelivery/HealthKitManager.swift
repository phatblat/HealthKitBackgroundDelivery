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
            debugPrint("Can't request access to HealthKit when it's not supported on the device.")
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
    /// Initiates an `HKAnchoredObjectQuery` for each type of data that the app reads and stores
    /// the result as well as the new anchor.
    func readHealthKitData() { /* ... */ }

    /// Sets up the observer queries for background health data delivery.
    ///
    /// - parameter types: Set of `HKObjectType` to observe changes to.
    private func setUpBackgroundDeliveryForDataTypes(types: Set<HKObjectType>) {
        for type in types {
            guard let sampleType = type as? HKSampleType else { print("ERROR: \(type) is not an HKSampleType"); continue }
            let query = HKObserverQuery(sampleType: sampleType, predicate: nil) { [weak self] (query: HKObserverQuery, completionHandler: HKObserverQueryCompletionHandler, error: NSError?) in
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
        case HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth)!:
            debugPrint("HKCharacteristicTypeIdentifierDateOfBirth") // not currently supported rdar://22221216
        case HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex)!:
            debugPrint("HKCharacteristicTypeIdentifierBiologicalSex")	// not currently supported rdar://22221216
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
    /// - returns: A set of HKObjectType.
    private func dataTypesToRead() -> Set<HKObjectType> {
        return Set(arrayLiteral:
            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth)!,
                   HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex)!,
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
