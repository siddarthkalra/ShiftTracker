//
//  ViewController.swift
//  ShiftTracker
//
//  Created by Crul on 2016-11-15.
//  Copyright © 2016 Sid. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // add waiter 1
        let waiter1: Waiter = Waiter.createWaiter(name: "Cenk")
        waiter1.addShift(start: Date(), end: Date())

        // add waiter 2
        let waiter2: Waiter = Waiter.createWaiter(name: "John")
        waiter2.addShift(start: Date(), end: Date())
        
        // save
        DatabaseHandler.saveContext()
        
        // show waiters
        
        // use optional binding
        if let searchResults = Waiter.getAllShifts() {
            for result in searchResults {
                print("Waiter \(result.name!)")
                
                for shift in result.shifts! as! Set<Shift> {
                    print("    has shift \(shift.startTime!) to \(shift.endTime!)")
                }
            }
        }
        
        // delete waiter 1
//        DatabaseHandler.getContext().delete(waiter1)
}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

