//
//  SemiRandomTimeGenerator.swift
//  AmeliaBoli
//
//  Created by Amelia Boli on 4/28/16.
//  Copyright © 2016 Amelia Boli. All rights reserved.
//

import Foundation
import EventKit

func getSemiRandomTimes() -> [NSDate] {
    
    let calendar = NSCalendar.currentCalendar()
    
    let userSettings = UserSettings.sharedInstance
    let message = Message.sharedInstance
    
    message.randomizeArray(message.messages, key: "randomizedMessages")
    
    var notificationTimes = [NSDate]()
    var dayToSchedule = NSDate()
    
    while notificationTimes.count < message.randomMessageIndexes.count {
        
        let numberOfReminders: Int
        switch userSettings.lastFrequencyPicked {
        case "hectic": numberOfReminders = userSettings.hecticNumber
        case "steady": numberOfReminders = userSettings.steadyNumber
        case "relaxed": numberOfReminders = userSettings.relaxedNumber
        default: numberOfReminders = userSettings.steadyNumber
        }
        
        let sectionLength = userSettings.periodLength / Double(numberOfReminders)
        var periodTimes = [0.0]
        var i = 0
        
        while periodTimes.count < numberOfReminders {
            periodTimes.append(periodTimes[i] + sectionLength)
            i += 1
        }
        
        var randomTimes = [NSTimeInterval]()
        
        let count = 4
        var sumToBeAveraged: UInt32 = 0
        var index = 0
        
        for time in periodTimes {
            
            while index < count {
                let randomTimeAddend = arc4random_uniform(UInt32(sectionLength))
                sumToBeAveraged += randomTimeAddend
                index += 1
            }
            
            index = 0
            
            let randomTime = Double(sumToBeAveraged) / Double(count)
            
            sumToBeAveraged = 0
            
            let timeToSchedule = time + randomTime
            randomTimes.append(timeToSchedule)
        }
                
        while !randomTimes.isEmpty {
            let randomTime = randomTimes.removeFirst()
            let totalMinutes = Int(randomTime + userSettings.startMinutesSinceMidnight)
            
            var dateToAdd = calendar.startOfDayForDate(dayToSchedule)
            dateToAdd = calendar.dateByAddingUnit(.Minute, value: totalMinutes, toDate: dateToAdd, options: [])!
            
            if calendar.compareDate(dateToAdd, toDate: NSDate(), toUnitGranularity: .Minute) == NSComparisonResult.OrderedDescending {
                notificationTimes.append(dateToAdd)
            }
        }
    
        let dayComponent = NSDateComponents()
        dayComponent.day = 1
        dayToSchedule = calendar.dateByAddingComponents(dayComponent, toDate: dayToSchedule, options: [])!
    
    }
    
    while notificationTimes.count > message.randomMessageIndexes.count {
        notificationTimes.removeLast()
    }
    
    return notificationTimes
}



