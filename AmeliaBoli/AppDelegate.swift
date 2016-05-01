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
        
        print("didFinishLaunchingWithOptions was called")
        if let options = launchOptions {
            if let notification = options[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
                if let userInfo = notification.userInfo {
                    let customField1 = userInfo["Index"] as! Int
                    // do something neat here
                }
            }
        }
//        let options = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey]
//        print(options)
//        
        return true
    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
       print("didReceive called")
        if application.applicationState == .Inactive {
            message.notificationMessage = notification.alertBody!
            message.notificationReceived = true
            if let userInfo = notification.userInfo {
                message.notificationIndex = userInfo["index"] as! Int
            }
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        message.scheduleMessageNotifications()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        message.notificationReceived = false
        userSettings.saveSettings()
        message.saveSettings()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        
        print("test")
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

