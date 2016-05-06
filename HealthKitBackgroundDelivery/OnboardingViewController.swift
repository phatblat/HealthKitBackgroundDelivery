//
//  OnboardingViewController.swift
//  HealthKitBackgroundDelivery
//
//  Created by Ben Chatelain on 5/5/16.
//  Copyright © 2016 Ben Chatelain. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
    @IBAction func didTapStartButton(sender: AnyObject) {
        debugPrint("didTapStartButton:")
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "OnboardingComplete")
    }
}

