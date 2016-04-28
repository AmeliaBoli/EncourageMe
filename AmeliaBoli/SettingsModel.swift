//
//  SettingsModel.swift
//  AmeliaBoli
//
//  Created by Amelia Boli on 4/21/16.
//  Copyright © 2016 Amelia Boli. All rights reserved.
//

import Foundation

struct UserSettings {
    let calendar = NSCalendar.currentCalendar()
    let components = NSDateComponents()
    
    var fromHour = 9
    var fromMinute = 0
    var fromTime: NSDate {
        get {
            components.hour = fromHour
            components.minute = fromMinute
            return calendar.dateFromComponents(components)!
        }
        set(newTime) {
            let components = calendar.components([.Hour, .Minute], fromDate: newTime)
            fromHour = components.hour
            fromMinute = components.minute
        }
    }
    
    var toHour = 17
    var toMinute = 0
    var toTime: NSDate {
        get {
            components.hour = toHour
            components.minute = toMinute
            return calendar.dateFromComponents(components)!
        }
        set(newTime) {
            let components = calendar.components([.Hour, .Minute], fromDate: newTime)
            toHour = components.hour
            toMinute = components.minute
        } 
    }
    
    var hecticNumber = 6
    var steadyNumber = 4
    var relaxedNumber = 2
}
