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
    
    override public var description: String {
        return "From \(DateHelper.stringFromDate(date: self.startTime!)) to \(DateHelper.stringFromDate(date: self.endTime!))."
    }
}
