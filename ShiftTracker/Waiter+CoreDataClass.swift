//
//  Waiter+CoreDataClass.swift
//  ShiftTracker
//
//  Created by Crul on 2016-11-15.
//  Copyright © 2016 Sid. All rights reserved.
//

import Foundation
import CoreData

@objc(Waiter)
public class Waiter: NSManagedObject {
    
    // MARK: - Members
    
    // MARK: - Static Methods
    
    class func createWaiter(name: String!) -> Waiter {
        let waiter: Waiter = NSEntityDescription.insertNewObject(forEntityName: String(describing: Waiter.self), into: DatabaseHandler.getContext()) as! Waiter
        waiter.name = name
        return waiter
    }
    
    class func deleteWaiter(waiter: Waiter) {
        DatabaseHandler.getContext().delete(waiter)
    }
    
    class func getAllShifts() -> [Waiter]? {
        let fetchRequest: NSFetchRequest<Waiter> = Waiter.fetchRequest()
        var searchResults: [Waiter]? = nil
        
        do {
            searchResults = try DatabaseHandler.getContext().fetch(fetchRequest) as [Waiter]
            print("number of results: \(searchResults?.count)")
        }
        catch {
            print("Error retrieving waiters -> \(error)")
        }
        
        return searchResults
    }
    
    // MARK: - Methods
    
    func deleteShift(shift: Shift) {
        self.removeFromShifts(shift)
        DatabaseHandler.getContext().delete(shift)
    }
}
