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
    let healthKitManager = HealthKitManager()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        if onboardingComplete {
            healthKitManager.requestAccessWithCompletion() { success, error in
                if success { print("HealthKit access granted") }
                else { print("Error requesting access to HealthKit: \(error)") }
            }
        }
        
        return true
    }
}
