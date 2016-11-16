//
//  WaiterListViewController.swift
//  ShiftTracker
//
//  Created by Crul on 2016-11-15.
//  Copyright © 2016 Sid. All rights reserved.
//

import UIKit

class WaiterListViewController: UITableViewController, UISearchResultsUpdating {

    // MARK: Constants
    
    static let WAITER_CELL_ID: String = "waiterCell"
    
    // MARK: Members
    
    var waiters: [[Waiter]] = []
    var filteredWaiters: [Waiter] = []
    var collation: UILocalizedIndexedCollation?
    let searchController = UISearchController(searchResultsController: nil)

    // MARK: Private Methods
    
    private func setupSearchController() {
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.definesPresentationContext = true
        self.tableView.tableHeaderView = searchController.searchBar
    }
    
    private func isSearchBarActive() -> Bool {
        return self.searchController.isActive && self.searchController.searchBar.text != ""
    }
    
    private func filterWaitersForSearchText(searchText: String, scope: String = "All") {
        let searchTextLowercased = searchText.lowercased()
        
        // Flatten out the 2D array and then filter it
        // This is done because the self.filteredWaiters is a 1D array as our search results
        // only need 1 section
        self.filteredWaiters = self.waiters.flatMap({ $0 }).filter({ (waiter: Waiter) -> Bool in
            return waiter.name!.lowercased().contains(searchTextLowercased)
        })
        
        self.tableView.reloadData()
    }
    
    // MARK: Event Handlers
    
    
    @IBAction func didTapAddButton(_ sender: Any) {
        print("add here")
    }
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        if let searchResults = Waiter.getAllShifts() {
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
        
        self.setupSearchController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if isSearchBarActive() {
            return 1
        }
        
        return self.collation!.sectionTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearchBarActive() {
            return self.filteredWaiters.count
        }
        
        return self.waiters[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WaiterListViewController.WAITER_CELL_ID, for: indexPath)
        let waiter: Waiter
        
        // Retrieve the waiter for this indexPath
        if isSearchBarActive() {
            waiter = self.filteredWaiters[indexPath.row]
        }
        else {
            waiter = self.waiters[indexPath.section][indexPath.row]
        }
        
        cell.textLabel?.text = waiter.name
        cell.detailTextLabel?.text = (waiter.shifts?.count)! > 0 ? "Shifts completed: \(waiter.shifts!.count)" : "No shifts found"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            // Waiter to delete
            let waiter: Waiter
            
            // Update the in memory data
            if self.isSearchBarActive() {
                waiter = self.filteredWaiters[indexPath.row]
                self.filteredWaiters.remove(at: indexPath.row)
            }
            else {
                waiter = self.waiters[indexPath.section][indexPath.row]
                self.waiters[indexPath.section].remove(at: indexPath.row)
            }
            
            // Animate the deletion of the row
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.right)
            
            // Delete waiter from the database
            // The CoreData context is saved in the AppDelegate
            Waiter.deleteWaiter(waiter: waiter)
        }
    }
    
    // MARK: Table View Section Methods
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (self.isSearchBarActive()) {
            return "Top Matches"
        }
        
        return self.collation?.sectionTitles[section];
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.collation?.sectionIndexTitles;
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return (self.collation?.section(forSectionIndexTitle: index))!
    }
    
    // MARK: UISearchResultsUpdating Delegate Methods
    
    func updateSearchResults(for searchController: UISearchController) {
        self.filterWaitersForSearchText(searchText: searchController.searchBar.text!)
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
