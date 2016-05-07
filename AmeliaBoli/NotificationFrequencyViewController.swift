//
//  NotificationFrequencyViewController.swift
//  AmeliaBoli
//
//  Created by Amelia Boli on 4/22/16.
//  Copyright © 2016 Amelia Boli. All rights reserved.
//

import UIKit

class NotificationFrequencyViewController: UIViewController {
    
    @IBOutlet weak var pickFrequencyView: UIView!
    @IBOutlet weak var welcomeView: UIView!
    
    let userSettings = UserSettings.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarHidden = true
        
        let lastLaunched = NSUserDefaults.standardUserDefaults().objectForKey("lastLaunched")
        if (lastLaunched as? NSDate) != nil {
            welcomeView.hidden = true
            let centerX = NSLayoutConstraint(item: pickFrequencyView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
            let centerY = NSLayoutConstraint(item: pickFrequencyView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
            let height = NSLayoutConstraint(item: pickFrequencyView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 22)
            pickFrequencyView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addConstraints([centerX, centerY, height])
        } else {
            NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "lastLaunched")
        }
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
