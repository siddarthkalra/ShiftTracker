//
//  Shift+CoreDataClass.swift
//  ShiftTracker
//
//  Created by Sid on 2016-11-15.
//  Copyright © 2016 Sid. All rights reserved.
//

import Foundation
import CoreData

@objc(Shift)
public class Shift: NSManagedObject {
    
    // MARK: - Static Methods
    
    class func createShift(start: Date!, end: Date!) -> Shift {
        let shift: Shift = NSEntityDescription.insertNewObject(forEntityName: String(describing: Shift.self), into: DatabaseHandler.getContext()) as! Shift
        shift.startTime =  start as NSDate?
        shift.endTime = end as NSDate?

        return shift
    }
}
