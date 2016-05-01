//
//  AppDelegate.swift
//  AmeliaBoli
//
//  Created by Amelia Boli on 4/19/16.
//  Copyright © 2016 Amelia Boli. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let userSettings = UserSettings.sharedInstance
    let message = Message.sharedInstance

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: nil))
        userSettings.loadSettings()
        message.loadSettings()
        
        return true
    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        message.notificationMessage = notification.alertBody!
        message.notificationReceived = true
        if let userInfo = notification.userInfo {
            message.notificationIndex = userInfo["index"] as? Int
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        message.scheduleMessageNotifications()
        message.registerShortcutItem()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        message.notificationReceived = false
        userSettings.saveSettings()
        message.saveSettings()
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationWillBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        if shortcutItem.type == "com.Amelia-Boli.AmeliaBoli.setFrequency" {
            switch shortcutItem.localizedTitle {
            case "Hectic": userSettings.lastFrequencyPicked = "hectic"
                case "Steady": userSettings.lastFrequencyPicked = "steady"
            case "Relaxed": userSettings.lastFrequencyPicked = "relaxed"
            default: print("Error with Home Screen Quick Actions")
            }
        completionHandler(true)
        } else if shortcutItem.type == "com.Amelia-Boli.AmeliaBoli.displayMessage" {
            message.notificationMessage = shortcutItem.localizedTitle
            message.notificationReceived = true
        }
        completionHandler(false)
        }
}

