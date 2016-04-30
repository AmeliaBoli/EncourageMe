//
//  NotificationFrequencyViewController.swift
//  AmeliaBoli
//
//  Created by Amelia Boli on 4/22/16.
//  Copyright © 2016 Amelia Boli. All rights reserved.
//

import UIKit

class NotificationFrequencyViewController: UIViewController {
    
    let userSettings = UserSettings.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarHidden = true
    }
    
    @IBAction func setNotificationFrequency(sender: UIButton) {
        switch sender.tag {
        case 0:
            userSettings.lastFrequencyPicked = "hectic"
        case 1:
            userSettings.lastFrequencyPicked = "steady"
        case 2:
            userSettings.lastFrequencyPicked = "relaxed"
        default: print("Error")
        }        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.sharedApplication().statusBarHidden = false
    }
}
