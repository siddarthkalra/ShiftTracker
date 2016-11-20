//
//  WaiterTests.swift
//  ShiftTracker
//
//  Created by Sid on 2016-11-18.
//  Copyright © 2016 Sid. All rights reserved.
//

import XCTest
import CoreData
@testable import ShiftTracker

class WaiterTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // delete everything
        let fetchRequest: NSFetchRequest<Waiter> = Waiter.fetchRequest()
        let searchResults: [Waiter] = try! DatabaseHandler.getContext().fetch(fetchRequest) as [Waiter]
        
        for result in searchResults {
            // delete saved waiter
            DatabaseHandler.getContext().delete(result)
        }
        
        // save the delete to disk
        DatabaseHandler.saveContext()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateWaiter() {
        let waiter = Waiter.createWaiter(name: "Test Waiter")
        XCTAssertTrue(waiter.name == "Test Waiter")
        
        // save to disk
        DatabaseHandler.saveContext()
        
        // get from disk
        let fetchRequest: NSFetchRequest<Waiter> = Waiter.fetchRequest()
        let searchResults: [Waiter] = try! DatabaseHandler.getContext().fetch(fetchRequest) as [Waiter]
        
        // check that only 1 result was returned
        XCTAssertTrue(searchResults.count == 1)
        
        let savedWaiter = searchResults.first
        
        // check that the saved waiter matches the created waiter
        XCTAssertTrue(waiter.name == savedWaiter?.name)
    }
    
    func testDeleteWaiter() {
        let waiter = Waiter.createWaiter(name: "Test Waiter")
        XCTAssertTrue(waiter.name == "Test Waiter")

        // save to disk
        DatabaseHandler.saveContext()
        
        // get from disk
        let fetchRequest: NSFetchRequest<Waiter> = Waiter.fetchRequest()
        let searchResults: [Waiter] = try! DatabaseHandler.getContext().fetch(fetchRequest) as [Waiter]
        
        // check that only 1 result was returned
        XCTAssertTrue(searchResults.count == 1)
        
        let savedWaiter = searchResults.first
        
        // check that the saved waiter matches the created waiter
        XCTAssertTrue(waiter.name == savedWaiter?.name)
        
        Waiter.deleteWaiter(waiter: savedWaiter!)
        
        // save to disk
        DatabaseHandler.saveContext()
        
        // get from disk
        let fetchRequest2: NSFetchRequest<Waiter> = Waiter.fetchRequest()
        let searchResults2: [Waiter] = try! DatabaseHandler.getContext().fetch(fetchRequest2) as [Waiter]
        
        // check that only 0 waiters were returned
        XCTAssertTrue(searchResults2.count == 0)
    }
    
    func testGetAllWaiters() {
        _ = Waiter.createWaiter(name: "Test Waiter1")
        _ = Waiter.createWaiter(name: "Test Waiter2")
        _ = Waiter.createWaiter(name: "Test Waiter3")
        
        // save to disk
        DatabaseHandler.saveContext()
        
        let waitersSearchResults = Waiter.getAllWaiters()
        XCTAssertTrue(waitersSearchResults?.count == 3)
        
        // sort the results
        let waiterSortedSearchResults = waitersSearchResults?.sorted(by: { (waiter1: Waiter, waiter2: Waiter) -> Bool in
            return waiter1.name! < waiter2.name!
        })
        
        XCTAssertTrue(waiterSortedSearchResults?[0].name == "Test Waiter1")
        XCTAssertTrue(waiterSortedSearchResults?[1].name == "Test Waiter2")
        XCTAssertTrue(waiterSortedSearchResults?[2].name == "Test Waiter3")
    }
    
    func testCreateDeleteShift() {
        let waiter = Waiter.createWaiter(name: "Test Waiter")
        let shift1 = Shift.createShift(start: Date(), end: Date())
        
        waiter.addToShifts(shift1)
        
        // save to disk
        DatabaseHandler.saveContext()
        
        // get from disk
        let fetchRequest: NSFetchRequest<Waiter> = Waiter.fetchRequest()
        let searchResults: [Waiter] = try! DatabaseHandler.getContext().fetch(fetchRequest) as [Waiter]
        
        // check that only 1 result was returned
        XCTAssertTrue(searchResults.count == 1)
        XCTAssertTrue((searchResults.first?.shifts?.count)! == 1)
        
        // delete shift
        waiter.deleteShift(shift: shift1)
        
        // save to disk
        DatabaseHandler.saveContext()
        
        // get from disk
        let fetchRequest2: NSFetchRequest<Waiter> = Waiter.fetchRequest()
        let searchResults2: [Waiter] = try! DatabaseHandler.getContext().fetch(fetchRequest2) as [Waiter]
        
        // check that only 1 result was returned
        XCTAssertTrue(searchResults2.count == 1)
        XCTAssertTrue((searchResults2.first?.shifts?.count)! == 0)
    }
}
