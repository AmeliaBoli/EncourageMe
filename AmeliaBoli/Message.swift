//
//  Message.swift
//  AmeliaBoli
//
//  Created by Amelia Boli on 4/28/16.
//  Copyright © 2016 Amelia Boli. All rights reserved.
//

import Foundation
import UIKit

private let filePath = NSBundle.mainBundle().pathForResource("Messages", ofType: "plist")!
private let messagesFromPlist = NSArray(contentsOfFile:filePath) as! Array<String>

class Message {
    static let sharedInstance = Message()
    
    let messages = messagesFromPlist
    var randomMessageIndexes: Array<Int> {
        get {
            let storedMessages = NSUserDefaults.standardUserDefaults().arrayForKey("randomizedMessages")
            if let storedRandomMessages = storedMessages as? Array<Int> where !storedRandomMessages.isEmpty {
                return storedRandomMessages
            } else {
                return randomizeArray(messages, key: "lastUsedMessage")
            }
        }
        set {
        }
    }
    
    // TODO: Fill in the rest of the data here
    let colors = [UIColor.redColor(), UIColor.blueColor(), UIColor.purpleColor()]
    var randomColorIndexes: Array<Int> {
        get {
            let storedColors = NSUserDefaults.standardUserDefaults().arrayForKey("randomizedColors")
            if let storedRandomColors = storedColors as? Array<Int> where !storedRandomColors.isEmpty {
                return storedRandomColors
            } else {
                return randomizeArray(colors, key: "lastUsedColor")
            }
        }
        set {
        }
    }
    
    func randomizeArray(array: Array<AnyObject>, key: String) -> Array<Int> {
        let count = array.count
        var randomizedArray = Array(0.stride(to: count, by: 1))
        let lastUsedIndex = NSUserDefaults.standardUserDefaults().integerForKey(key)
        
        while randomizedArray.count < messages.count {
            var j = 0
            while j < colors.count {
                randomizedArray.append(j)
                j += 1
            }
        }
        
        repeat {
            repeat {
                var i = 0
                while i < randomizedArray.count - 1 {
                    let randomIndex = Int(arc4random_uniform(UInt32(randomizedArray.count)))
                    if i != randomIndex {
                        swap(&randomizedArray[i], &randomizedArray[randomIndex])
                        i += 1
                    }
                }
            } while randomizedArray[0] == lastUsedIndex
        } while checkForConsecutiveDuplicates(randomizedArray)
        
        NSUserDefaults.standardUserDefaults().setInteger(randomizedArray.last!, forKey: key)
        return randomizedArray
    }
    
    func checkForConsecutiveDuplicates(array: Array<Int>) -> Bool {
        for (index, element) in array.enumerate() {
            if index == array.count - 1 {
                return false
            }
            if array[element] == array[index + 1] {
                return true
            }
        }
        return false
    }
    
    func createTodaysItem(array: Array<AnyObject>, randomIndexes: Array<Int>, key: String) -> AnyObject{
        var randomIndexes = randomIndexes
        let todaysIndex = randomIndexes.removeFirst()
        let todaysItem = array[todaysIndex]
        NSUserDefaults.standardUserDefaults().setObject(randomIndexes, forKey: key)
        return todaysItem
    }
    
    func scheduleMessageNotifications() {
        let myApplication = UIApplication.sharedApplication()
        let currentSettings = myApplication.currentUserNotificationSettings()
        let alert: UIUserNotificationType = .Alert
        if let settings = currentSettings where settings.types.contains(alert) {
            let randomTimes = getSemiRandomTimes()
            print(randomTimes)
            var notifications = [UILocalNotification]()
            
            for (time, index) in zip(randomTimes, randomMessageIndexes) {
                let notification = UILocalNotification()
                notification.alertBody = messages[index]
                notification.fireDate = time
                notifications.append(notification)
            }
            //print(notifications)
            myApplication.scheduledLocalNotifications = notifications
        }
    }
}
