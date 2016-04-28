//
//  NotificationFrequencyViewController.swift
//  AmeliaBoli
//
//  Created by Amelia Boli on 4/22/16.
//  Copyright © 2016 Amelia Boli. All rights reserved.
//

import UIKit

class NotificationFrequencyViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func setNotificationFrequency(sender: UIButton) {
        switch sender.tag {
        case 0: scheduleNotifications("hectic")
        case 1: scheduleNotifications("steady")
        case 2: scheduleNotifications("relaxed")
        default: print("Error")
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}
