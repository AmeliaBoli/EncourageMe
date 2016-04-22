//
//  ViewController.swift
//  AmeliaBoli
//
//  Created by Amelia Boli on 4/19/16.
//  Copyright © 2016 Amelia Boli. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var toolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarStyle = .LightContent
            }
    
    override func viewWillAppear(animated: Bool) {
        let lastLaunched = NSUserDefaults.standardUserDefaults().objectForKey("lastLaunched")
        if let lastLaunchedDate = lastLaunched as? NSDate {
            let calendar = NSCalendar.currentCalendar()
            if !calendar.isDateInToday(lastLaunchedDate) {
                //presentFirstTimeOnlyView
                print("Worked")
                NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "lastLaunched")
            }
        } else {
            //launch Onboarding
            NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "lastLaunched")
            print(NSUserDefaults.standardUserDefaults().objectForKey("lastLaunched"))
        }
    }
    
    @IBAction func presentShareController(sender: UIBarButtonItem) {
        let image = UIImage()
        let activityView = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        self.presentViewController(activityView, animated: true, completion: nil)
    }
    
    @IBAction func manageToolbar(recognizer: UITapGestureRecognizer) {
        if toolbar.hidden == true {
            toolbar.hidden = false
        } else {
            toolbar.hidden = true
        }
    }

}

