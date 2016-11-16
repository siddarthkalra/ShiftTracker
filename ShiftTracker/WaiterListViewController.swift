//
//  WaiterListViewController.swift
//  ShiftTracker
//
//  Created by Crul on 2016-11-15.
//  Copyright © 2016 Sid. All rights reserved.
//

import UIKit

class WaiterListViewController: UITableViewController {

    // MARK: Constants
    
    static let WAITER_CELL_ID: String = "waiterCell"
    
    // MARK: Members
    
    var waiters: [[Waiter]] = []
    var collation: UILocalizedIndexedCollation?
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // TEMP 
        
//        // add waiter 1
//        let waiter1: Waiter = Waiter.createWaiter(name: "Zed")
//        waiter1.addShift(start: Date(), end: Date())
//        
//        // add waiter 2
//        let waiter2: Waiter = Waiter.createWaiter(name: "Ked")
//        waiter2.addShift(start: Date(), end: Date())
//        
//        let waiter3: Waiter = Waiter.createWaiter(name: "Med")
//        let waiter4: Waiter = Waiter.createWaiter(name: "Sid")
//        let waiter5: Waiter = Waiter.createWaiter(name: "Larry")
//        let waiter6: Waiter = Waiter.createWaiter(name: "Jane")
////        waiter2.addShift(start: Date(), end: Date())
//        
//        // save
//        DatabaseHandler.saveContext()
        
        // TEMP
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        if let searchResults = Waiter.getAllShifts() {
            //self.waiters = searchResults
            self.collation = UILocalizedIndexedCollation.current()
            
            if let collation = self.collation {
                var tempWaiters: [[Waiter]] = []
                let sectionTitlesCount: Int = collation.sectionTitles.count
                
                // setup the sections
                for _ in 0..<sectionTitlesCount {
                    let tempArray: [Waiter] = []
                    tempWaiters.append(tempArray)
                }
                
                // go through the list of waiters and put them in the appropriate section array
                for result in searchResults {
                    let sectionNumber: Int = collation.section(for: result, collationStringSelector: #selector(getter: Waiter.name))
                    tempWaiters[sectionNumber].append(result)
                }
                
                // now sort each section array
                for index in 0..<sectionTitlesCount {
                    let tempArrayForSection:[Waiter] = tempWaiters[index]
                    
                    let sortedWaiterArray:[Waiter] = collation.sortedArray(from: tempArrayForSection,
                                                                           collationStringSelector: #selector(getter: Waiter.name)) as! [Waiter]
                    
                    // now use the sorted array
                    tempWaiters[index] = sortedWaiterArray
                }
                
                self.waiters = tempWaiters
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.collation!.sectionTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.waiters[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WaiterListViewController.WAITER_CELL_ID, for: indexPath)

        // Retrieve the waiter for this indexPath
        let waiter: Waiter = self.waiters[indexPath.section][indexPath.row]
        
        cell.textLabel?.text = waiter.name
        cell.detailTextLabel?.text = (waiter.shifts?.count)! > 0 ? "Shifts completed: \(waiter.shifts!.count)" : "No shifts found"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
        }
    }
    
    // MARK: Table View Section Methods
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.collation?.sectionTitles[section];
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.collation?.sectionIndexTitles;
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return (self.collation?.section(forSectionIndexTitle: index))!
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
