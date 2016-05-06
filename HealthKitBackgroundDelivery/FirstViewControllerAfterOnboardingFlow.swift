//
//  FirstViewControllerAfterOnboardingFlow.swift
//  HealthKitBackgroundDelivery
//
//  Created by Ben Chatelain on 5/5/16.
//  Copyright © 2016 Ben Chatelain. All rights reserved.
//

import UIKit

class FirstViewControllerAfterOnboardingFlow: UIViewController {
    let healthKitManager = HealthKitManager()

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if !NSUserDefaults.standardUserDefaults().boolForKey("OnboardingComplete") {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let onboarding = storyboard.instantiateViewControllerWithIdentifier("Onboarding")
            presentViewController(onboarding, animated: true) {
                debugPrint("Onboarding not complete, presenting modal")
            }
        } else {
            debugPrint("Onboarding has been completed, requesting access to HealthKit")
            healthKitManager.requestAccessWithCompletion() { success, error in
                if success { debugPrint("HealthKit access granted") }
                else { print("Error requesting access to HealthKit: \(error)") }
            }
        }
    }
}
