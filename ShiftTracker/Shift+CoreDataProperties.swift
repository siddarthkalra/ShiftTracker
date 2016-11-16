//
//  Shift+CoreDataProperties.swift
//  ShiftTracker
//
//  Created by Crul on 2016-11-15.
//  Copyright © 2016 Sid. All rights reserved.
//

import Foundation
import CoreData


extension Shift {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Shift> {
        return NSFetchRequest<Shift>(entityName: "Shift");
    }

    @NSManaged public var startTime: NSDate?
    @NSManaged public var endTime: NSDate?

}
