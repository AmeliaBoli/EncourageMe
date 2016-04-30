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
    @IBOutlet weak var messageLabel: UILabel!
    
    var message = Message.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.reloadView))
        swipeLeft.direction = .Left
        self.view.addGestureRecognizer(swipeLeft)
        
        messageLabel.text = message.createTodaysItem(message.messages, randomIndexes: message.randomMessageIndexes, key: "randomizedMessages") as? String
        view.backgroundColor = message.createTodaysItem(message.colors, randomIndexes: message.randomColorIndexes, key: "randomizedColors") as? UIColor
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.checkForPickerDisplay), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        checkForPickerDisplay()
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    func checkForPickerDisplay() {
        let lastLaunched = NSUserDefaults.standardUserDefaults().objectForKey("lastLaunched")
        if let lastLaunchedDate = lastLaunched as? NSDate {
            let calendar = NSCalendar.currentCalendar()
            if !calendar.isDateInToday(lastLaunchedDate) {
                let controller: NotificationFrequencyViewController
                controller = storyboard?.instantiateViewControllerWithIdentifier("notificationFrequency") as! NotificationFrequencyViewController
                self.presentViewController(controller, animated: true, completion: nil)
                
                NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "lastLaunched")
            }
        } else {
            // TODO: Launch Onboarding
            NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "lastLaunched")
        }
    }
    
    @IBAction func presentShareController(sender: UIBarButtonItem) {
        let toolbarIsHidden = toolbar.hidden
        if !toolbarIsHidden {
            toolbar.hidden = true
        }
        let messageToShare = MessageToShare(message: messageLabel.text!, backgroundColor: view.backgroundColor!, messageToShare: generateMessageToShare())
        if !toolbarIsHidden {
            toolbar.hidden = false

        let activityView = UIActivityViewController(activityItems: [messageToShare.messageToShare], applicationActivities: nil)
        self.presentViewController(activityView, animated: true, completion: nil)
        }
    }
    
    func reloadView() {
        messageLabel.text = message.createTodaysItem(message.messages, randomIndexes: message.randomMessageIndexes, key: "randomizedMessages") as? String
        view.backgroundColor = message.createTodaysItem(message.colors, randomIndexes: message.randomColorIndexes, key: "randomizedColors") as? UIColor
    }
       
    @IBAction func manageToolbar(recognizer: UITapGestureRecognizer) {
        if toolbar.hidden  == true {
            toolbar.hidden = false
        } else {
            toolbar.hidden = true
        }
    }
    
    func generateMessageToShare() -> UIImage
    {
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame,
                                     afterScreenUpdates: true)
        let messageToShare : UIImage =
            UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return messageToShare
    }
    
    struct MessageToShare {
        let message: String
        let backgroundColor: UIColor
        let messageToShare: UIImage
    }


}

