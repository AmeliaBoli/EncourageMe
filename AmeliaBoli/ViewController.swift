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
    var previousColor = UIColor()
    
    var index = 0
    var viewInFrontIndex = 0
   
    var xTotalMoved = CGFloat(0)
    let screenBounds = UIScreen.mainScreen().bounds
    
    var isPop = true
    
    var message = Message.sharedInstance
    
    var velocities = [CGFloat]()
    var cycledThrough = false
    var movementStatus = MovementStatus.none
    var viewInTheMiddleOfMovingOn = false
    var screenWidth: CGFloat = 0

    enum MovementStatus {case none, left, right}
    
    // Arrays of stuff to test things out
    let messages = [ "You Make a Difference", 
        "I Admire Your Passion", 
        "Try It One More Time", 
        "Smile. You Are Beautiful!", 
        "The Best is Yet to Come"]

    let colors = [UIColor(red:0.859, green:0.384, blue:0, alpha:1), // orange #db6200
    UIColor(red:0.404, green:0, blue:0.749, alpha:1), // purple #6700bf
    UIColor(red:0.122, green:0.647, blue:0, alpha:1), // green (blue-er) #1fa500
    UIColor(red:0.655, green:0, blue:0.714, alpha:1), // violet #a700b6
    UIColor(red:0.706, green:0, blue:0, alpha:1)] // red #b40000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        let inFrontViewDetails = (message: messages[0], backgroundColor: colors[0])
        messageLabelInFront.text = inFrontViewDetails.message //messages[0] //message.createTodaysItem(message.messages, randomIndexes: &message.randomMessageIndexes, lastUsedIndex: &message.lastUsedMessage) as? String
        viewInFront.backgroundColor = inFrontViewDetails.backgroundColor //colors[0] //message.createTodaysItem(message.colors, randomIndexes: &message.randomColorIndexes, lastUsedIndex: &message.lastUsedColor) as? UIColor
        
        let inBackViewDetails = (message: messages[1], backgroundColor: colors[1])
        messageLabelInBack.text = inBackViewDetails.message //messages[1]
        viewInBack.backgroundColor = inBackViewDetails.backgroundColor //colors[1]
        
        message.registerShortcutItem()
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        screenWidth = screenSize.width
        
        // Set message font size
        let foursScreenWidth = CGFloat(320)
        let screenPercentIncrease = screenWidth / foursScreenWidth
        let newMessageFontSize = messageLabelInFront.font.pointSize * screenPercentIncrease
        messageLabelInFront.font.fontWithSize(newMessageFontSize)
        messageLabelInBack.font.fontWithSize(newMessageFontSize)
        
        toolbar.isAccessibilityElement = true
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.checkForNotification), name: UIApplicationDidBecomeActiveNotification, object: nil)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.checkForSpecialView), name: UIApplicationDidBecomeActiveNotification, object: nil)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.reloadView), name: UIApplicationDidBecomeActiveNotification, object: nil)
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
    
    // MARK: Animation
    
    func averageVelocity() -> CGFloat {
        let lastVelocitiesQuantity = 20
        let velocitiesToExclude = CGFloat(1.0)
        
        let velocitiesToAverage = velocities.suffix(lastVelocitiesQuantity)
        let normalizedVelocities = velocitiesToAverage.filter {abs($0) >= velocitiesToExclude}
        let summedVelocities = normalizedVelocities.reduce(0) {$0 + $1}
        let averagedVelocity = abs(summedVelocities / CGFloat(normalizedVelocities.count))
        
        return averagedVelocity
    }
    
    func makeDuration(transform: CATransform3D, velocity: CGFloat) -> Double {
        let durationRange = (min: 0.4, max: 1.5)
        
        let distanceToTravel = transform.m41 - viewInFront.layer.transform.m41
        var duration = abs(Double(distanceToTravel / velocity))
        
        if duration < durationRange.min {
            duration = durationRange.min
        } else if duration > durationRange.max {
            duration = durationRange.max
        }
        return duration
    }

    @IBAction func handlePan(sender: UIPanGestureRecognizer) {
        
        if sender.state == .Changed {
            
            let xTranslation = sender.translationInView(view).x
            velocities.append(sender.velocityInView(view).x)
            
            guard xTranslation != 0 else {
                return
            }
            
            let maximumRightMovement: CGFloat = 25

            if xTranslation < 0 || (xTranslation > 0 && index == 0 && !cycledThrough) {
                
                if xTotalMoved >= maximumRightMovement && xTranslation > 0 {
                    panGesture.enabled = false
                    
                    let transform = CATransform3DIdentity
                    
                    let anim = CABasicAnimation(keyPath: "transform")
                    anim.toValue = NSValue(CATransform3D: transform)
                    anim.fromValue = NSValue(CATransform3D: viewInFront.layer.transform)
                    anim.duration = 0.5
                    anim.delegate = self
                    anim.setValue("rightMovementReturned", forKey: "animationName")
                    
                    viewInFront.layer.addAnimation(anim, forKey: "rightMovementReturned")
                    viewInFront.layer.transform = transform
                    
                } else {
                    
                    let newTranslationTransform = CATransform3DMakeTranslation(xTranslation, 0, 0)
                    
                    let newTranslation = CATransform3DConcat((CATransform3D: viewInFront.layer.transform), newTranslationTransform)
                    viewInFront.layer.transform = newTranslation
                    
                    xTotalMoved += xTranslation
                    sender.setTranslation(CGPointZero, inView: view)
                    
                    if movementStatus == .none {
                        movementStatus = .left
                    }
                }
                
            } else if xTranslation > 0 && (index != 0 || cycledThrough) {
                
                // Reposition Views
                if !viewInTheMiddleOfMovingOn {
                    var previousIndex = index - 1
                    if index <= 0 {
                        previousIndex = colors.count - 1
                    }
                    
                    viewInBack.backgroundColor = colors[index]
                    messageLabelInBack.text = messages[index]
                    viewInFront.hidden = true
                    viewInFront.backgroundColor = colors[previousIndex]
                    messageLabelInFront.text = messages[previousIndex]
                    
                    let frame = viewInFront.frame
                    let myXTranslation = -(frame.minX + frame.width)
                    
                    let translationTransform = CATransform3DMakeTranslation(myXTranslation, 0, 0)
                    
                    viewInFront.layer.transform = CATransform3DConcat((CATransform3D: viewInFront.layer.transform), translationTransform)
                    viewInFront.layer.transform = translationTransform
                    viewInFront.hidden = false
                    
                    viewInTheMiddleOfMovingOn = true
                }
                
                // Dragging View
                guard viewInFront.layer.frame.origin.x < viewInFront.layer.position.x - viewInFront.layer.frame.size.width + maximumRightMovement else {
                    return
                }
                
                let newTranslationTransform = CATransform3DMakeTranslation(xTranslation, 0, 0)
                viewInFront.layer.transform = CATransform3DConcat((CATransform3D: viewInFront.layer.transform), newTranslationTransform)
                
                xTotalMoved += xTranslation
                sender.setTranslation(CGPointZero, inView: view)
                
                if movementStatus == .none {
                    movementStatus = .right
                }
            }
        }
        
        if sender.state == .Ended {
            
            panGesture.enabled = false
            
            var thresholdMet = false
            
            switch movementStatus {
            case .left: if xTotalMoved <= -screenWidth * 0.2 {thresholdMet = true}
            case .right: if xTotalMoved >= screenWidth * 0.1 {thresholdMet = true}
            case .none: return
            }
            
            if thresholdMet {
                
                var transform = CATransform3D()
                let frame = viewInFront.frame
                
                // Animating a view on or off the screen completely
                switch movementStatus {
                case .left:
                    let newX = -(frame.width + screenWidth) / 2
                    let translationTransform = CATransform3DMakeTranslation(newX, 0, 0)
                    transform = translationTransform
                case .right:
                    transform = CATransform3DIdentity
                case .none: return
                }
                
                let anim = CABasicAnimation(keyPath: "transform")
                anim.fromValue = NSValue(CATransform3D: viewInFront.layer.transform)
                anim.toValue = NSValue(CATransform3D: transform)
                anim.duration = makeDuration(transform, velocity: averageVelocity())
                anim.delegate = self
                anim.setValue("thresholdMet", forKey: "animationName")
                
                viewInFront.layer.addAnimation(anim, forKey: "thresholdMet")
                viewInFront.layer.transform = transform
                
            } else {
                // Returning a view with animation to it's starting position at the beginning of the gesture
                var animationDescription = ""
                var transform = CATransform3D()
                
                switch movementStatus {
                case .left: transform = CATransform3DIdentity
                animationDescription = "returnToMiddle"
                case .right:  let frame = viewInFront.frame
                let newX = -(frame.width + screenWidth) / 2
                transform = CATransform3DMakeTranslation(newX, 0, 0)
                animationDescription = "returnOffScreen"
                case .none: return
                }
                
                let anim = CABasicAnimation(keyPath: "transform")
                anim.toValue = NSValue(CATransform3D: transform)
                anim.fromValue = NSValue(CATransform3D: viewInFront.layer.transform)
                anim.duration = 0.5
                anim.speed = 2.0
                anim.delegate = self
                anim.setValue(animationDescription, forKey: "animationName")
                
                viewInFront.layer.addAnimation(anim, forKey: animationDescription)
                viewInFront.layer.transform = transform
            }
        }
    }

    func repositionViews() {
        var nextIndex = index + 1
        if nextIndex >= colors.count {
            nextIndex = 0
        }
        
        viewInFront.hidden = true
        viewInFront.backgroundColor = colors[index]
        messageLabelInFront.text = messages[index]
        
        viewInFront.layer.transform = CATransform3DIdentity
        
        viewInFront.hidden = false
        viewInBack.backgroundColor = colors[nextIndex]
        messageLabelInBack.text = messages[nextIndex]
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if let animationName = anim.valueForKey("animationName") as? String where animationName == "thresholdMet" {
            
            // Repositioning views
            switch movementStatus {
            case .left:
                index += 1
                if index >= colors.count {
                    index = 0
                    cycledThrough = true
                }
                
                repositionViews()
            case .right:
                index -= 1
                if index < 0 {
                    index = colors.count - 1
                }
                
            case .none: break
            }
        }
        
        if let animationName = anim.valueForKey("animationName") as? String where animationName == "returnOffScreen" && movementStatus == .right {
            repositionViews()
        }
        
        movementStatus = .none
        viewInTheMiddleOfMovingOn = false
        panGesture.enabled = true
        xTotalMoved = 0
    }
    
    
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
    
    // END Animation
    
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

