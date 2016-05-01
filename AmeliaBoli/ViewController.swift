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
        
        messageLabel.text = message.createTodaysItem(message.messages, randomIndexes: &message.randomMessageIndexes, lastUsedIndex: &message.lastUsedMessage) as? String
        view.backgroundColor = message.createTodaysItem(message.colors, randomIndexes: &message.randomColorIndexes, lastUsedIndex: &message.lastUsedColor) as? UIColor
    }
    
    override func viewWillAppear(animated: Bool) {
        print("viewWillAppear")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.checkForNotification), name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.checkForPickerDisplay), name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.reloadView), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        checkForPickerDisplay()
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    func checkForNotification() {
        if message.notificationReceived {
            print(message.randomMessageIndexes)
            messageLabel.text = message.notificationMessage
            if let usedIndex = message.randomMessageIndexes.indexOf(message.notificationIndex) {
                message.randomMessageIndexes.removeAtIndex(usedIndex)
            }
            print(message.randomMessageIndexes)
         }
    }
    
    func checkForPickerDisplay() {
        if !message.notificationReceived {
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
        if !message.notificationReceived {
            messageLabel.text = message.createTodaysItem(message.messages, randomIndexes: &message.randomMessageIndexes, lastUsedIndex: &message.lastUsedMessage) as? String
            view.backgroundColor = message.createTodaysItem(message.colors, randomIndexes: &message.randomColorIndexes, lastUsedIndex: &message.lastUsedColor) as? UIColor
        }
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

