//
//  AppDelegate.swift
//  HealthKitBackgroundDelivery
//
//  Created by Ben Chatelain on 5/5/16.
//  Copyright © 2016 Ben Chatelain. All rights reserved.
//

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let healthKitManager = HealthKitManager()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        if NSUserDefaults.standardUserDefaults().boolForKey("OnboardingComplete") {
            debugPrint("Onboarding has been completed, requesting access to HealthKit")
            healthKitManager.requestAccessWithCompletion() { success, error in
                if success { debugPrint("HealthKit access granted") }
                else { print("Error requesting access to HealthKit: \(error)") }
            }
        }
        
        return true
    }
}
