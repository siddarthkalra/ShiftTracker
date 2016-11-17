//
//  Shift+CoreDataClass.swift
//  ShiftTracker
//
//  Created by Crul on 2016-11-15.
//  Copyright © 2016 Sid. All rights reserved.
//

import Foundation
import CoreData

@objc(Shift)
public class Shift: NSManagedObject {
    
    static let DATE_FORMAT: String = "MMM d h:mma"
    
    override public var description: String {
        return "\(DateHelper.stringFromDate(date: self.startTime!, withDateFormat: Shift.DATE_FORMAT)) to \(DateHelper.stringFromDate(date: self.endTime!, withDateFormat: Shift.DATE_FORMAT))"
    }
}
