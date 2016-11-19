//
//  Waiter+CoreDataProperties.swift
//  ShiftTracker
//
//  Created by Sid on 2016-11-15.
//  Copyright © 2016 Sid. All rights reserved.
//

import Foundation
import CoreData


extension Waiter {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Waiter> {
        return NSFetchRequest<Waiter>(entityName: "Waiter");
    }

    @NSManaged public var name: String?
    @NSManaged public var shifts: NSSet?

}

// MARK: Generated accessors for shifts
extension Waiter {

    @objc(addShiftsObject:)
    @NSManaged public func addToShifts(_ value: Shift)

    @objc(removeShiftsObject:)
    @NSManaged public func removeFromShifts(_ value: Shift)

    @objc(addShifts:)
    @NSManaged public func addToShifts(_ values: NSSet)

    @objc(removeShifts:)
    @NSManaged public func removeFromShifts(_ values: NSSet)

}
