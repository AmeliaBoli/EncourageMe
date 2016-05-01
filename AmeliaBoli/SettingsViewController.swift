//
//  SettingsViewController.swift
//  AmeliaBoli
//
//  Created by Amelia Boli on 4/21/16.
//  Copyright © 2016 Amelia Boli. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var toTimeField: UITextField!
    @IBOutlet weak var fromTimeField: UITextField!
    @IBOutlet weak var hecticNumber: UILabel!
    @IBOutlet weak var steadyNumber: UILabel!
    @IBOutlet weak var relaxedNumber: UILabel!
    @IBOutlet weak var hecticStepper: UIStepper!
    @IBOutlet weak var steadyStepper: UIStepper!
    @IBOutlet weak var relaxedStepper: UIStepper!
    
    var userSettings = UserSettings.sharedInstance
    var message = Message.sharedInstance
    
    var timeFormatter: NSDateFormatter {
        get {
            let timeFormatter = NSDateFormatter()
                timeFormatter.dateFormat = "h:mm a"
            return timeFormatter
        }
    }
       
    override func viewDidLoad() {
        super.viewDidLoad()
        
         UIApplication.sharedApplication().statusBarStyle = .Default
        
        // Dismiss UIDatePicker on tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.dismissDatePicker))
        view.addGestureRecognizer(tap)
        
        fromTimeField.text = String(format: "\(userSettings.fromHour):%02d AM", userSettings.fromMinute)
        
        let toHourTwelve: Int
        if userSettings.toHour > 12 {
            toHourTwelve = userSettings.toHour - 12
        } else {
            toHourTwelve = userSettings.toHour
        }
        
        toTimeField.text = String(format: "\(toHourTwelve):%02d PM", userSettings.toMinute)
        hecticNumber.text = "\(userSettings.hecticNumber) a day"
        steadyNumber.text = "\(userSettings.steadyNumber) a day"
        relaxedNumber.text = "\(userSettings.relaxedNumber) a day"
        hecticStepper.value = Double(userSettings.hecticNumber)
        steadyStepper.value = Double(userSettings.steadyNumber)
        relaxedStepper.value = Double(userSettings.relaxedNumber)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let lastLaunched = NSUserDefaults.standardUserDefaults().objectForKey("lastLaunched")
        if (lastLaunched as? NSDate) == nil {
            let onboardingController: OnboardingViewController
            onboardingController = self.storyboard?.instantiateViewControllerWithIdentifier("firstLaunch") as! OnboardingViewController
            self.presentViewController(onboardingController, animated: true, completion: nil)
        }
    }
    
    @IBAction func edittingBegan(sender: UITextField) {
        let datePicker = UIDatePicker(frame: CGRectZero)
        datePicker.datePickerMode = .Time
        datePicker.minuteInterval = 15
        datePicker.setDate(timeFormatter.dateFromString(sender.text!)!, animated: true)
        datePicker.addTarget(self, action: #selector(SettingsViewController.timeChanged), forControlEvents: .ValueChanged)
        sender.inputView = datePicker
    }
    
    func timeChanged(datePicker: UIDatePicker) {
        let date = datePicker.date
        
        if fromTimeField.isFirstResponder() {
            var fromTime: String
            if !checkTimes(date, firstResponder: fromTimeField) {
                fromTime = toTimeField.text!
                userSettings.fromTime = timeFormatter.dateFromString(fromTime)!
            } else {
                fromTime = timeFormatter.stringFromDate(date)
                userSettings.fromTime = date
            }
            self.fromTimeField.text = fromTime
        } else {
            var toTime: String
            if !checkTimes(date, firstResponder: toTimeField) {
                toTime = fromTimeField.text!
                userSettings.toTime = timeFormatter.dateFromString(toTime)!
            } else {
                toTime = timeFormatter.stringFromDate(date)
                userSettings.toTime = date
            }
            self.toTimeField.text = toTime
        }
    }
    
    func checkTimes(date: NSDate, firstResponder: UITextField) -> Bool {
        let comparingTime: NSDate
        if firstResponder == fromTimeField {
            comparingTime = userSettings.toTime
            let comparingDate = createComparableDate(date, comparingTime: comparingTime)
            if date.timeIntervalSinceDate(comparingDate) > 0 {
                return false
            } else {
                return true
            }
        } else {
            comparingTime = userSettings.fromTime
            let comparingDate = createComparableDate(date, comparingTime: comparingTime)
            if date.timeIntervalSinceDate(comparingDate) < 0 {
                return false
            } else {
                return true
            }
        }
    }
    
    func createComparableDate(date: NSDate, comparingTime: NSDate) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let comparingTimeComp = calendar.components([.Hour, .Minute], fromDate: comparingTime)
        let todayDateComp = calendar.components([.Year, .Month, .Day], fromDate: date)
        let combinedComp = NSDateComponents()
        combinedComp.year = todayDateComp.year
        combinedComp.month = todayDateComp.month
        combinedComp.day = todayDateComp.day
        combinedComp.hour = comparingTimeComp.hour
        combinedComp.minute = comparingTimeComp.minute
        let comparingDate = calendar.dateFromComponents(combinedComp)!
        return comparingDate
    }
    
    func dismissDatePicker() {
        view.endEditing(true)
    }
    
    @IBAction func messageNumberChanged(sender: UIStepper) {
        switch sender.tag {
        case 0: hecticNumber.text = "\(Int(sender.value)) a day"
        case 1: steadyNumber.text = "\(Int(sender.value)) a day"
        case 2: relaxedNumber.text = "\(Int(sender.value)) a day"
        default: print("Error with stepper")
        }
    }
    
    @IBAction func donePressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: {
            let lastLaunched = NSUserDefaults.standardUserDefaults().objectForKey("lastLaunched")
            if let lastLaunchedDate = lastLaunched as? NSDate {
                let calendar = NSCalendar.currentCalendar()
                if !calendar.isDateInToday(lastLaunchedDate) {
                    let controller: NotificationFrequencyViewController
                    controller = self.storyboard?.instantiateViewControllerWithIdentifier("notificationFrequency") as! NotificationFrequencyViewController
                    self.presentViewController(controller, animated: true, completion: nil)
                    
                    NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "lastLaunched")
                }
            }
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        userSettings.hecticNumber = Int(hecticStepper.value)
        userSettings.steadyNumber = Int(steadyStepper.value)
        userSettings.relaxedNumber = Int(relaxedStepper.value)
        
        
        
        let userSettingsDict = ["fromHour": userSettings.fromHour,
                                "fromMinute": userSettings.fromMinute,
                                "toHour": userSettings.toHour,
                                "toMinute": userSettings.toMinute,
                                "hecticNumber": userSettings.hecticNumber,
                                "steadyNumber": userSettings.steadyNumber,
                                "relaxedNumber": userSettings.relaxedNumber]
        NSUserDefaults.standardUserDefaults().setObject(userSettingsDict, forKey: "userSettings")
    }
}
