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
    let message = Message.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func setNotificationFrequency(sender: UIButton) {
        switch sender.tag {
        case 0:
            NSUserDefaults.standardUserDefaults().setObject("hectic", forKey: "frequency")
        case 1:
            NSUserDefaults.standardUserDefaults().setObject("steady", forKey: "frequency")
        case 2:
            NSUserDefaults.standardUserDefaults().setObject("relaxed", forKey: "frequency")
        default: print("Error")
        }
        
        message.scheduleMessageNotifications()
        dismissViewControllerAnimated(true, completion: nil)
    }
}
