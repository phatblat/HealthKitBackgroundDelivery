//
//  HKSampleTypeNameSpec.swift
//  HealthKitBackgroundDelivery
//
//  Created by Ben Chatelain on 5/5/16.
//  Copyright © 2016 Ben Chatelain. All rights reserved.
//

@testable import HealthKitBackgroundDelivery
import Quick
import Nimble
import HealthKit

class HKSampleTypeNameSpec: QuickSpec {
    override func spec() {
        describe("hk sample type name") {
            var sample: HKSampleType!
            beforeEach {}
            it("is body mass") {
                sample = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!
                expect(sample.typeName) == "HKQuantityTypeIdentifierBodyMass"
            }
            it("is height") {
                sample = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)!
                expect(sample.typeName) == "HKQuantityTypeIdentifierHeight"
            }
            it("is workout type identifier") {
                sample = HKObjectType.workoutType()
                expect(sample.typeName) == "HKWorkoutTypeIdentifier"
            }
        }
    }
}
