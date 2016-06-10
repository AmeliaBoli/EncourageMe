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
    @IBOutlet weak var viewInBack: UIView!
    @IBOutlet weak var messageLabelInBack: UILabel!
    @IBOutlet weak var viewInFront: UIView!
    @IBOutlet weak var messageLabelInFront: UILabel!
    
    @IBOutlet weak var viewInFrontLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var swipeLeftGesture: UISwipeGestureRecognizer!
    
    var viewOffScreen = UIView()
    var frameAfterRotation = CGRect()
    var previousColor = UIColor()
    
    var index = 0
    let totalRotation = CGFloat(M_PI / 12)
    var totalRotated = CGFloat(0)
    var totalMoved = CGFloat(0)
    let screenBounds = UIScreen.mainScreen().bounds
    
    var message = Message.sharedInstance
    
    // Arrays of stuff to test things out
    let messages = [ "You Make a Difference", 
        "I Admire Your Passion", 
        "Try It One More Time", 
        "Smile. You Are Beautiful!", 
        "The Best is Yet to Come"]

    let colors = [UIColor(red:0.859, green:0.384, blue:0, alpha:1), // orange #db6200
    UIColor(red:0.404, green:0, blue:0.749, alpha:1), // purple #6700bf
    UIColor(red:0.122, green:0.647, blue:0, alpha:1), // green (bluer) #1fa500
    UIColor(red:0.655, green:0, blue:0.714, alpha:1), // violet #a700b6
    UIColor(red:0.706, green:0, blue:0, alpha:1)] // red #b40000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        let inFrontViewDetails = retrieveNextViewDetails()
        messageLabelInFront.text = inFrontViewDetails.message //messages[0] //message.createTodaysItem(message.messages, randomIndexes: &message.randomMessageIndexes, lastUsedIndex: &message.lastUsedMessage) as? String
        viewInFront.backgroundColor = inFrontViewDetails.backgroundColor //colors[0] //message.createTodaysItem(message.colors, randomIndexes: &message.randomColorIndexes, lastUsedIndex: &message.lastUsedColor) as? UIColor
        
        let inBackViewDetails = retrieveNextViewDetails()
        messageLabelInBack.text = inBackViewDetails.message //messages[1]
        viewInBack.backgroundColor = inBackViewDetails.backgroundColor //colors[1]
        
        message.registerShortcutItem()
        
        // Set message font size
        let foursScreenWidth = CGFloat(320)
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        let screenPercentIncrease = screenWidth / foursScreenWidth
        let newMessageFontSize = messageLabelInFront.font.pointSize * screenPercentIncrease
        messageLabelInFront.font.fontWithSize(newMessageFontSize)
        messageLabelInBack.font.fontWithSize(newMessageFontSize)
        
//        viewInFront.layer.anchorPoint = CGPoint(x: 0.5, y: 0.9)
//        viewInBack.layer.anchorPoint = CGPoint(x: 0.5, y: 0.9)
    }
    
    override func viewDidLayoutSubviews() {
//        viewInFront.frame = CGRect(origin: CGPointZero, size: screenBounds.size)
//        viewInBack.frame = CGRect(origin: CGPointZero, size: screenBounds.size)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.checkForNotification), name: UIApplicationDidBecomeActiveNotification, object: nil)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.checkForSpecialView), name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.reloadView), name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    func checkForNotification() {
        if message.notificationReceived {
            messageLabelInFront.text = message.notificationMessage
            if let index = message.notificationIndex, let usedIndex = message.randomMessageIndexes.indexOf(index) {
                message.randomMessageIndexes.removeAtIndex(usedIndex)
            }
            view.backgroundColor = message.createTodaysItem(message.colors, randomIndexes: &message.randomColorIndexes, lastUsedIndex: &message.lastUsedColor) as? UIColor
         }
    }
    
    func checkForSpecialView() {
        if !message.notificationReceived {
            let lastLaunched = NSUserDefaults.standardUserDefaults().objectForKey("lastLaunched")
            if let lastLaunchedDate = lastLaunched as? NSDate {
                let calendar = NSCalendar.currentCalendar()
                if !calendar.isDateInToday(lastLaunchedDate) {
                    NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "lastLaunched")

                    let controller: NotificationFrequencyViewController
                    controller = storyboard?.instantiateViewControllerWithIdentifier("notificationFrequency") as! NotificationFrequencyViewController
                    self.presentViewController(controller, animated: true, completion: nil)
                }
            } else {
                let controller: NotificationFrequencyViewController
                controller = storyboard?.instantiateViewControllerWithIdentifier("notificationFrequency") as! NotificationFrequencyViewController
                self.presentViewController(controller, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func swipeLeft(recognizer: UISwipeGestureRecognizer) {
        
        let rotationTransform = CGAffineTransformMakeRotation(-CGFloat(M_PI / 10))
        frameAfterRotation = CGRectApplyAffineTransform(self.viewInFront.frame, rotationTransform)
        view.layoutIfNeeded()
        
        UIView.animateWithDuration(0.6, delay: 0, options: [.CurveEaseIn, .LayoutSubviews], animations: {
            self.viewInFrontLeadingConstraint.constant = -(self.frameAfterRotation.width - (self.frameAfterRotation.width - self.viewInFront.frame.width) / 2)
            self.viewInFront.transform = CGAffineTransformMakeRotation(-CGFloat(M_PI / 10))
            self.view.layoutIfNeeded()
            }, completion: { finished in
                if finished {
                    print(self.viewInFront.frame)
                    self.progressContent()
                }
        })

        
        
//        let screenWidth = screenBounds.width
//        let percentMovedBeforeRemoving = CGFloat(0.8)
//        let totalMovedBeforeRemoving = (screenWidth / 2) * percentMovedBeforeRemoving
//        
//        //let translation = recognizer.translationInView(view)
//        
//        
//        if recognizer.state == .Changed && abs(totalMoved) >= totalMovedBeforeRemoving {
//            swipeLeftGesture.enabled = false
//            finishAnimatingOffScreen()
//            
//        } else {
//            //let percentToRotate = translation.x / (screenBounds.width / 2)
//            
//            //totalRotated += CGFloat(percentToRotate * totalRotation)
//            //totalMoved += translation.x
//            
//            //viewInFront.transform = CGAffineTransformMakeRotation(totalRotated)
//            //viewInFront.center = CGPoint(x: (viewInFront.center.x + translation.x), y: viewInFront.center.y)
//        }
//        //recognizer.setTranslation(CGPointZero, inView: view)
    }

    func retrieveNextViewDetails() -> (message: String, backgroundColor: UIColor){
        if index == messages.count {
            //make new messages and background colors array
            index = 0
        }
        
        let newViewDetails = (message: messages[index], backgroundColor: colors[index])
        index += 1
        
        return newViewDetails
    }
    
    func progressContent() {
        viewInFront.hidden = true
        //previousColor = viewInFront.backgroundColor!
        messageLabelInFront.text = messageLabelInBack.text!
        viewInFront.backgroundColor = viewInBack.backgroundColor
        
        view.layoutIfNeeded()
        
        UIView.animateWithDuration(0, delay: 0, options: .CurveEaseOut, animations: {
            self.viewInFrontLeadingConstraint.constant = 0
            self.viewInFront.transform = CGAffineTransformMakeRotation(0)
            self.view.layoutIfNeeded()
            }, completion: { finished in
                if finished {
                    self.viewInFront.hidden = false
                    let nextViewDetails = self.retrieveNextViewDetails()
                    self.messageLabelInBack.text = nextViewDetails.message
                    self.viewInBack.backgroundColor = nextViewDetails.backgroundColor
                }
        })
        
    }

    func finishAnimatingOffScreen() {
        view.layoutIfNeeded()
        
        let totalRotationTransform = CGAffineTransformMakeRotation(-1.1)
        let finalViewFrame = CGRectApplyAffineTransform(self.viewInFront.frame, totalRotationTransform)
        let xToMove: CGFloat = -(finalViewFrame.width / 2 + self.viewInFront.center.x)
        
        
//         This code was working until I started moving views around. I'm commenting it out to try messing with constraints.
        let rightBoundingConstraint = NSLayoutConstraint(item: viewInFront, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1, constant: 100)
        
        UIView.animateWithDuration(1, animations: {
            //self.viewInFront.transform = CGAffineTransformMakeRotation(-1.1)
            //self.view.removeConstraint(self.viewInFrontTrailingConstraint) //constant = -self.screenBounds.width
            self.view.removeConstraint(self.viewInFrontLeadingConstraint)
                self.view.addConstraint(rightBoundingConstraint)
                self.view.layoutIfNeeded()
            
            //self.viewInFront.center = CGPoint(x: self.viewInFront.center.x + xToMove, y: self.viewInFront.center.y)
            
            }, completion: { finished in
                if finished {
                    //self.moveViews()
                    self.swipeLeftGesture.enabled = true
                    self.totalRotated = 0
                    self.totalMoved = 0
                }
        })
        
        //self.viewInFrontTrailingConstraintToSuperView = rightBoundingConstraint

    }
    
//    func moveViews() {
//        viewInFront.hidden = true
//        //viewInFront.center = CGPoint(x: screenBounds.width / 2, y: screenBounds.height / 2)
//        //viewInFront.transform = CGAffineTransformMakeRotation(-totalRotated + 1.1)
//        viewInFront.frame = CGRect(origin: CGPointZero, size: screenBounds.size)
//        
//        if indexDisplayed == messages.count - 1 {
//            indexDisplayed = 0
//        } else {
//            indexDisplayed += 1
//        }
//
//        viewInFront.backgroundColor = viewInBack.backgroundColor
//        messageLabelInFront.text = messageLabelInBack.text
//        
//        viewInFront.hidden = false
//        
//        viewInBack.backgroundColor = colors[indexDisplayed]
//        messageLabelInBack.text = messages[indexDisplayed]
//    }
    
    @IBAction func presentShareController(sender: UIBarButtonItem) {
        let toolbarIsHidden = toolbar.hidden
        if !toolbarIsHidden {
            toolbar.hidden = true
        }
        let messageToShare = MessageToShare(message: messageLabelInFront.text!, backgroundColor:  view.backgroundColor!, messageToShare: generateMessageToShare())
        if !toolbarIsHidden {
            toolbar.hidden = false

        let activityView = UIActivityViewController(activityItems: [messageToShare.messageToShare], applicationActivities: nil)
        self.presentViewController(activityView, animated: true, completion: nil)
        }
    }
    
    func reloadView() {
        if !message.notificationReceived {
            messageLabelInFront.text = message.createTodaysItem(message.messages, randomIndexes: &message.randomMessageIndexes, lastUsedIndex: &message.lastUsedMessage) as? String
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

