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
    
    @IBOutlet weak var panGesture: UIPanGestureRecognizer!
    
    var viewOffScreen = UIView()
    var originalFrame = CGRect()
    var frameAfterRotation = CGRect()
    var previousColor = UIColor()
    
    var index = 0
    var viewInFrontIndex = 0
    let totalRotation = CGFloat(M_PI / 12)
    var totalRotated = CGFloat(0)
    var totalMoved = CGFloat(0)
    let screenBounds = UIScreen.mainScreen().bounds
    
    var isPop = true
    
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
        
        toolbar.isAccessibilityElement = true
        
        let rotationTransform = CGAffineTransformMakeRotation(-totalRotation)
        frameAfterRotation = CGRectApplyAffineTransform(screenBounds, rotationTransform)

        viewInFront.layer.anchorPoint = CGPoint(x: 0.5, y: 0.9)
//        viewInBack.layer.anchorPoint = CGPoint(x: 0.5, y: 0.9)
    }
    
    override func viewDidLayoutSubviews() {
        viewInFront.frame = CGRect(origin: CGPointZero, size: screenBounds.size)
        //let viewInFrontCopy = viewInFront.copy()
        originalFrame = viewInFront.frame
        print("Original frame \(originalFrame)")
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
    
    @IBAction func handlePan(sender: UIPanGestureRecognizer) {
        let screenWidth = screenBounds.width
        let percentMovedBeforeRemoving = CGFloat(0.6)
        let xTranslation = sender.translationInView(view).x
        
        if sender.state == .Changed {
            
            if viewInFrontIndex != 0 && xTranslation > 0 {
                panGesture.enabled = false
                
               
                
                //let translationTransform = CATransform3DMakeTranslation(frameAfterRotation.width, 0, 0)
                //let rotationTransform = CATransform3DMakeRotation(0, 0, 0, 1)
                //let finalTransform = CATransform3DConcat(translationTransform, rotationTransform)
                let identityTransform = CATransform3DIdentity
                let timing = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
                
                
                let anim = CABasicAnimation(keyPath: "transform")
                anim.fromValue = NSValue(CATransform3D: viewInFront.layer.transform) //NSValue(CGPoint: viewInFront.layer.position)
                anim.toValue = NSValue(CATransform3D: identityTransform)
                anim.duration = 0.8
                anim.timingFunction = timing
                anim.delegate = self
                
                self.viewInFront.layer.addAnimation(anim, forKey: "returnToScreen")
                self.viewInFront.layer.transform = identityTransform
                //viewInFront.transform = CGAffineTransformIdentity
                
                //viewInFront.layer.position = CGPointZero
                //viewInFront.frame = originalFrame
                print("Frame at end \(originalFrame)")//viewInFront.frame)")

            } else if totalMoved >= -(screenWidth * percentMovedBeforeRemoving) {
                
                if totalMoved >= (screenWidth * percentMovedBeforeRemoving) && xTranslation > 0 {
                    return
                }
                
                totalMoved += xTranslation
                let percentOfScreenMoved = totalMoved / screenWidth
                
                let translation = CGAffineTransformMakeTranslation(totalMoved, 0)
                let rotation = CGAffineTransformMakeRotation(percentOfScreenMoved * totalRotation)
                
                self.viewInFront.transform = CGAffineTransformConcat(translation, rotation)
            
            } else {
                panGesture.enabled = false
                
                let translationTransform = CATransform3DMakeTranslation(-frameAfterRotation.width, 0, 0)
                let rotationTransform = CATransform3DMakeRotation(-totalRotation, 0, 0, 1)
                let finalTransform = CATransform3DConcat(translationTransform, rotationTransform)
                
                let timing = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
                
                let anim = CABasicAnimation(keyPath: "transform")
                anim.fromValue = NSValue(CATransform3D: viewInFront.layer.transform)
                anim.toValue = NSValue(CATransform3D: finalTransform)
                anim.duration = 0.8
                anim.timingFunction = timing
                anim.delegate = self
                
                self.viewInFront.layer.addAnimation(anim, forKey: "moveOffScreen")
                self.viewInFront.layer.transform = finalTransform
            }
        }
        sender.setTranslation(CGPointZero, inView: view)
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        panGesture.enabled = true
        viewInFrontIndex += 1
        totalMoved = 0
        print("---Presentation---\(viewInFront.layer.presentationLayer())")
        print("---Model---\(viewInFront.layer.modelLayer())")
        print("Final frame \(originalFrame)")//viewInFront.frame)")
    }
    
    @IBAction func swipeLeft(recognizer: UISwipeGestureRecognizer) {
        
        //isPop = true
        
        //let rotationTransform = CGAffineTransformMakeRotation(-CGFloat(M_PI / 10))
        //frameAfterRotation = CGRectApplyAffineTransform(self.viewInFront.frame, rotationTransform)
        //view.layoutIfNeeded()
        
//        UIView.animateWithDuration(0.6, delay: 0, options: [.CurveEaseIn, .LayoutSubviews], animations: {
//            self.viewInFrontLeadingConstraint.constant = -(self.frameAfterRotation.width - (self.frameAfterRotation.width - self.viewInFront.frame.width) / 2)
//            self.viewInFront.transform = CGAffineTransformMakeRotation(-CGFloat(M_PI / 10))
//            self.view.layoutIfNeeded()
//            }, completion: { finished in
//                if finished {
//                    print(self.viewInFront.frame)
//                    self.progressContent()
//                }
//        })
        
//        let screenWidth = screenBounds.width
//        let percentMovedBeforeRemoving = CGFloat(0.8)
//        
//        if recognizer.state == .Changed {
//            if abs(totalMoved) < (screenWidth * percentMovedBeforeRemoving) {
//                let xTranslation = recognizer.translationInView(view).x
//                
//                if xTranslation < 0 {
//                    //viewInFront.center = CGPoint(x: viewInFront.center.x + xTranslation, y: viewInFront.center.y)
//                    totalViewMoved += xTranslation
//                    let percentOfScreenMoved = totalViewMoved / screenWidth
//                    //                    viewInFrontLeadingConstraint.constant = totalViewMoved
//                    //                    viewInFront.transform = CGAffineTransformMakeRotation(percentOfScreenMoved * totalRotationRadian)
//                    let translation = CGAffineTransformMakeTranslation(totalViewMoved, 0)
//                    let rotation = CGAffineTransformMakeRotation(percentOfScreenMoved * totalRotationRadian)
//                    //UIView.animateWithDuration(0.0) {
//                    print(totalViewMoved);
//                    print(percentOfScreenMoved * totalRotationRadian);
//                    self.viewInFront.transform = CGAffineTransformConcat(translation, rotation)
//                    //}
//                }
//            } else {
//                sender.enabled = false
//                
//                let translationTransform = CATransform3DMakeTranslation(-self.frameAfterRotation.width, 0, 0)
//                //                let rotationTransform = CATransform3DMakeRotation(-self.totalRotationRadian, 0, 0, 1)
//                //                let finalTransform = CATransform3DConcat(translationTransform, rotationTransform)
//                //
//                //
//                //                // keyPath mean property we're goint to animate
//                //                // animations method will grab all available keys
//                //                let anim = CABasicAnimation (keyPath: "transform")
//                //                anim.fromValue = NSValue (CATransform3D: self.viewInFront.layer.transform)
//                //                anim.toValue = NSValue (CATransform3D: finalTransform)
//                //                anim.duration = 1.5
//                //
//                //                // animation key is a "handle" that you can use to e.g. remove the animation
//                //                self.viewInFront.layer.addAnimation(anim, forKey: "test!")
//                //
//                //                self.viewInFront.layer.transform = finalTransform;
//                //
//                //                view.layoutIfNeeded()
//                
//                //questions for ui team- can i do it with UIView?
//                //where do I need layoutIfNeeded
//                //will transform take care of constraints
//                
//                //view.layoutIfNeeded()
//
//                
//                UIView.animateWithDuration(1.5, delay: 1.5, options: [], animations: {
//                    //self.viewInFrontLeadingConstraint.constant = -(self.frameAfterRotation.width - (self.frameAfterRotation.width - self.viewInFront.frame.width) / 2)
//                    //self.viewInFront.center = CGPoint(x: -self.frameAfterRotation.width / 2, y: self.viewInFront.center.y)
//                    //self.viewInFront.transform = CGAffineTransformMakeRotation(-self.totalRotationRadian)
//                    let translation = CGAffineTransformMakeTranslation(-self.frameAfterRotation.width, 0)
//                    let rotation = CGAffineTransformMakeRotation(-self.totalRotationRadian)
//                    
//                    //                    print(-self.frameAfterRotation.width);
//                    //                    print(-self.totalRotationRadian);
//                    self.viewInFront.transform = CGAffineTransformConcat(translation, rotation)
//                    //self.view.layoutIfNeeded()
//                    }, completion: nil)
//                
//            }
//            sender.setTranslation(CGPointZero, inView: view)
        }


        
        

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
//    }

    @IBAction func swipeRight(recognizer: UISwipeGestureRecognizer) {
        // set back view to front view
        // hide front view
        // move front view to the left
        // load previous index in the front view
        // animate front view back on top
        
        isPop = false
        
        viewInBack.backgroundColor = viewInFront.backgroundColor
        messageLabelInBack.text = messageLabelInFront.text!
        
        viewInFront.hidden = true
        
        view.layoutIfNeeded()
        UIView.animateWithDuration(0, delay: 0, options: [.CurveEaseIn, .LayoutSubviews], animations: {
            self.viewInFrontLeadingConstraint.constant = -(self.frameAfterRotation.width - (self.frameAfterRotation.width - self.viewInFront.frame.width) / 2)
            self.viewInFront.transform = CGAffineTransformMakeRotation(-CGFloat(M_PI / 10))
            self.view.layoutIfNeeded()
            }, completion: { finished in
                if finished {
                    let nextViewDetails = self.retrieveNextViewDetails()
                    self.viewInFront.backgroundColor = nextViewDetails.backgroundColor
                    self.messageLabelInFront.text = nextViewDetails.message
                    
                    self.view.layoutIfNeeded()
                    
                    UIView.animateWithDuration(0.6, delay: 0, options: [.CurveEaseOut, .LayoutSubviews], animations: {
                        self.viewInFrontLeadingConstraint.constant = 0
                        self.viewInFront.transform = CGAffineTransformMakeRotation(-CGFloat(0))
                        self.view.layoutIfNeeded()
                    }, completion: nil)
                }})
                    
                    //                    let newViewDetails = self.retrieveNextViewDetails()
//                    
//                    print(self.viewInFront.frame)
                    //self.progressContent()
                }
    
    func retrieveNextViewDetails() -> (message: String, backgroundColor: UIColor){
        if index == messages.count {
            //make new messages and background colors array
            index = 0
        }
        
        let newViewDetails = (message: messages[index], backgroundColor: colors[index])
        
        if isPop {
            index += 1
        } else {
            index -= 1
        }
        
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

