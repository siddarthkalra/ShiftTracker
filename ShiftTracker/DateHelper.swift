//
//  DateHelper.swift
//  ShiftTracker
//
//  Created by Sid on 2016-11-15.
//  Copyright © 2016 Sid. All rights reserved.
//

import Foundation

class DateHelper {
    
    class func stringFromDate(date: NSDate) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        return dateFormatter.string(from: date as Date)
    }
    
    class func stringFromDate(date: NSDate, withDateFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format

        return dateFormatter.string(from: date as Date)
    }
    
    class func stringFromDate(date: Date, withDateFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: date)
    }
    
    class func datesAreOnSameDay(date1: Date, date2: Date) -> Bool {
        let userCalender: Calendar = Calendar.current
        return userCalender.compare(date1, to: date2, toGranularity: .day) == .orderedSame
    }
}
