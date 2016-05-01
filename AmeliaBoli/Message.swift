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
    
    private init() {
    }
    
    let messages = messagesFromPlist
    var randomMessageIndexes = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 ,15, 16, 17, 18, 19, 20, 21]
    var lastUsedMessage = 21
    
    let colors = [UIColor(red:0.859, green:0.384, blue:0, alpha:1), // orange #db6200
        UIColor(red:0.404, green:0, blue:0.749, alpha:1), // purple #6700bf
        UIColor(red:0.122, green:0.647, blue:0, alpha:1), // green (bluer) #1fa500
        UIColor(red:0.655, green:0, blue:0.714, alpha:1), // violet #a700b6
        UIColor(red:0.706, green:0, blue:0, alpha:1), // red #b40000
        //UIColor(red:0.886, green:0.812, blue:0, alpha:1), // yellow (gold) #e2cf00
        UIColor(red:0.765, green:0, blue:0.467, alpha:1), // magenta #c30077
        UIColor(red:0.522, green:0.792, blue:0, alpha:1), // green (yellower) #c30077
        UIColor(red:0, green:0.243, blue:0.686, alpha:1)] // blue #003eaf]
    
    var randomColorIndexes = [0, 1, 2, 3, 4, 5, 6, 7]
    var lastUsedColor = 7
    
    var notificationMessage = ""
    var notificationIndex = 0
    var notificationReceived = false
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    func loadSettings() {
        if let storedRandomizedMessages = userDefaults.arrayForKey("randomizedMessages") as? Array<Int> where !storedRandomizedMessages.isEmpty {
            randomMessageIndexes = storedRandomizedMessages
        } else {
            randomMessageIndexes = randomizeArray(messages, lastUsed: &lastUsedMessage)
        }
        if let storedRandomizedColors = userDefaults.arrayForKey("randomizedColors") as? Array<Int> where !storedRandomizedColors.isEmpty {
            randomColorIndexes = storedRandomizedColors
        } else {
            randomColorIndexes = randomizeArray(colors, lastUsed: &lastUsedColor)
        }
        if let storedLastMessage = userDefaults.objectForKey("lastUsedMessage") as? Int {
            lastUsedMessage = storedLastMessage
        } else {
            lastUsedMessage = randomMessageIndexes.last!
        }
        if let storedLastColor = userDefaults.objectForKey("lastUsedColor") as? Int {
            lastUsedColor = storedLastColor
        } else {
            lastUsedColor = randomColorIndexes.last!
        }
    }
    
    func randomizeArray(array: Array<AnyObject>, inout lastUsed: Int) -> (Array<Int>) {
        let count = array.count
        var randomizedArray = Array(0.stride(to: count, by: 1))
        
        repeat {
            var i = 0
            while i < randomizedArray.count - 1 {
                let randomIndex = Int(arc4random_uniform(UInt32(randomizedArray.count)))
                if i != randomIndex {
                    swap(&randomizedArray[i], &randomizedArray[randomIndex])
                    i += 1
                }
            }
        } while randomizedArray[0] == lastUsed
        
        lastUsed = randomizedArray.last!
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
    
    func createTodaysItem(array: Array<AnyObject>, inout randomIndexes: Array<Int>, inout lastUsedIndex: Int) -> AnyObject {
        if randomIndexes.isEmpty {
            randomIndexes = randomizeArray(array, lastUsed: &lastUsedIndex)
        }
        let todaysIndex = randomIndexes.removeFirst()
        let todaysItem = array[todaysIndex]
        return todaysItem
    }
    
    func scheduleMessageNotifications() {
        let myApplication = UIApplication.sharedApplication()
        let currentSettings = myApplication.currentUserNotificationSettings()
        let alert: UIUserNotificationType = .Alert
        if let settings = currentSettings where settings.types.contains(alert) {
            let randomTimes = getSemiRandomTimes()
            var notifications = [UILocalNotification]()
            
            for (time, index) in zip(randomTimes, randomMessageIndexes) {
                let notification = UILocalNotification()
                notification.alertBody = messages[index]
                notification.fireDate = time
                notification.userInfo = ["index": index]
                notifications.append(notification)
            }
            myApplication.scheduledLocalNotifications = notifications
        }
    }
    
    func saveSettings() {
        userDefaults.setObject(randomMessageIndexes, forKey: "randomizedMessages")
        userDefaults.setObject(lastUsedMessage, forKey: "lastUsedMessage")
        userDefaults.setObject(randomColorIndexes, forKey: "randomizedColors")
        userDefaults.setObject(lastUsedColor, forKey: "lastUsedColor")
    }
}