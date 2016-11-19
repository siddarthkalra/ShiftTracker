//
//  WaiterListViewController.swift
//  ShiftTracker
//
//  Created by Crul on 2016-11-15.
//  Copyright © 2016 Sid. All rights reserved.
//

import UIKit

protocol WaiterUpdateDelegate {
    func add(waiterTableInfo: WaiterTableInfo, with animation: UITableViewRowAnimation)
    func update(waiterTableInfo: WaiterTableInfo, atIndexPath indexPath: IndexPath, with animation: UITableViewRowAnimation)
    func delete(waiterTableInfo: WaiterTableInfo?, atIndexPath indexPath: IndexPath, with animation: UITableViewRowAnimation)
    func updateShifts(waiterTableInfo: WaiterTableInfo, atIndexPath indexPath: IndexPath, with animation: UITableViewRowAnimation)
    func deleteShift(waiterTableInfo: WaiterTableInfo, atIndexPath indexPath: IndexPath, with animation: UITableViewRowAnimation)
}

struct WaiterTableInfo {
    var origIndexPath: IndexPath? // holds the original indexPath
    var waiter: Waiter
}

class WaiterListViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate,
                                WaiterUpdateDelegate, UINavigationControllerDelegate {
    
    // MARK: Constants
    
    static let CELL_ID_WAITER: String = "waiterCell"
    static let SEGUE_WAITER_DETAIL: String = "waiterDetailSegue"
    static let SECTION_HEADER_SEARCH: String = "Top Matches"
    
    static let LABEL_SCALE_FACTOR: CGFloat = 0.8
    
    // MARK: Members
    
    var waiters: [[Waiter]] = []
    var filteredWaiters: [WaiterTableInfo] = []
    var collation: UILocalizedIndexedCollation?
    let searchController = UISearchController(searchResultsController: nil)
    var shouldReloadTable = false

    // MARK: Private Methods
    
    private func setupSearchController() {
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.definesPresentationContext = true
        self.searchController.searchBar.delegate = self
        
        self.tableView.tableHeaderView = self.searchController.searchBar
        
        self.definesPresentationContext = true
    }
    
    private func isSearchBarActive() -> Bool {
        return self.searchController.isActive && self.searchController.searchBar.text != ""
    }
    
    private func filterWaitersForSearchText(searchText: String, scope: String = "All") {
        let searchTextLowercased = searchText.lowercased()
        
        // Flatten out the 2D array and then filter it
        // This is done because the self.filteredWaiters is a 1D array as our search results
        // only need 1 section
        self.filteredWaiters = []
        
        for (section, waiterArray) in self.waiters.enumerated() {
            for (row, waiter) in waiterArray.enumerated() {
                if waiter.name!.lowercased().contains(searchTextLowercased) {
                    self.filteredWaiters.append(WaiterTableInfo(origIndexPath: IndexPath(row: row, section: section), waiter: waiter))
                }
            }
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: Event Handlers
    
    @IBAction func didTapAddButton(_ sender: Any) {
        self.performSegue(withIdentifier: WaiterListViewController.SEGUE_WAITER_DETAIL, sender: self)
    }
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.delegate = self;
        
        self.tableView.sectionIndexColor = StyleManager.themeColor;
        
        if let searchResults = Waiter.getAllWaiters() {
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
        
        self.shouldReloadTable = false
        self.setupSearchController()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table View Data Source Methods

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
        let cell = tableView.dequeueReusableCell(withIdentifier: WaiterListViewController.CELL_ID_WAITER, for: indexPath)
        let waiter: Waiter
        
        // Retrieve the waiter for this indexPath
        if isSearchBarActive() {
            waiter = self.filteredWaiters[indexPath.row].waiter
        }
        else {
            waiter = self.waiters[indexPath.section][indexPath.row]
        }
        
        cell.textLabel?.text = waiter.name
        cell.detailTextLabel?.text = (waiter.shifts?.count)! > 0 ? "Shifts completed: \(waiter.shifts!.count)" : "No shifts found"
        
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.minimumScaleFactor = WaiterListViewController.LABEL_SCALE_FACTOR

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            self.delete(waiterTableInfo: nil, atIndexPath: indexPath, with: .automatic)
        }
    }
    
    // MARK: - Table View Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: WaiterListViewController.SEGUE_WAITER_DETAIL, sender: indexPath)
    }
    
    // MARK: Table View Section Methods
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (self.isSearchBarActive()) {
            return WaiterListViewController.SECTION_HEADER_SEARCH
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
    
    // MARK: UISearchBarDelegate Methods
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if self.shouldReloadTable {
            self.shouldReloadTable = false
            self.tableView.reloadData()
        }
    }
    
    // MARK: WaiterUpdateDelegate Delegate Methods
    
    internal func update(waiterTableInfo: WaiterTableInfo, atIndexPath indexPath: IndexPath, with animation: UITableViewRowAnimation) {
        if let collation = self.collation {
            let newSectionNumber: Int = collation.section(for: waiterTableInfo.waiter, collationStringSelector: #selector(getter: Waiter.name))
            
            if newSectionNumber != waiterTableInfo.origIndexPath?.section {
                // The Waiter's name has been changed such that it now belongs in a
                // different section
                
                // Delete Waiter from original section
                self.waiters[(waiterTableInfo.origIndexPath?.section)!].remove(at: (waiterTableInfo.origIndexPath?.row)!)
                
                if isSearchBarActive() {
                    self.filteredWaiters.remove(at: indexPath.row)
                }
                
                // Delete the row from the table view
                // Here we don't use origIndexPath because the search bar coulde be active
                // so we need to use the current indexPath
                self.tableView.deleteRows(at: [indexPath], with: animation)
                
                // Add to new section
                self.add(waiterTableInfo: waiterTableInfo, with: animation)
            }
            else {
                self.tableView.reloadRows(at: [indexPath], with: animation)
            }
        }
    }
    
    internal func delete(waiterTableInfo: WaiterTableInfo?, atIndexPath indexPath: IndexPath, with animation: UITableViewRowAnimation) {
        var curWaiterTableInfo:WaiterTableInfo? = waiterTableInfo
        
        // Update the in-memory data
        if self.isSearchBarActive() {
            if curWaiterTableInfo == nil {
                curWaiterTableInfo = self.filteredWaiters[indexPath.row]
            }
            self.filteredWaiters.remove(at: indexPath.row)
            
            // Use the original index path to update the waiters data array
            self.waiters[(curWaiterTableInfo?.origIndexPath?.section)!].remove(at: (curWaiterTableInfo?.origIndexPath?.row)!)
            self.shouldReloadTable = true
        }
        else {
            if curWaiterTableInfo == nil {
                curWaiterTableInfo = WaiterTableInfo(origIndexPath: indexPath, waiter: self.waiters[indexPath.section][indexPath.row])
            }
            self.waiters[indexPath.section].remove(at: indexPath.row)
        }
        
        // delete row
        self.tableView.deleteRows(at: [indexPath], with: animation)
        
        // Delete waiter from the database
        // The CoreData context is saved in the AppDelegate
        if curWaiterTableInfo != nil {
            Waiter.deleteWaiter(waiter: (curWaiterTableInfo?.waiter)!)
        }
    }
    
    internal func add(waiterTableInfo: WaiterTableInfo, with animation: UITableViewRowAnimation) {
        // Note: the user can't add a waiter while the search bar is active as the
        // add new waiter button is hidden so we don't need to manipulate self.filteredWaiters in this function
        if let collation = self.collation {
            let sectionNumber: Int = collation.section(for: waiterTableInfo.waiter, collationStringSelector: #selector(getter: Waiter.name))
            var tempArrayForSection: [Waiter] = self.waiters[sectionNumber]
            
            tempArrayForSection.append(waiterTableInfo.waiter)
            
            let sortedWaiterArray:[Waiter] = collation.sortedArray(from: tempArrayForSection,
                                                                   collationStringSelector: #selector(getter: Waiter.name)) as! [Waiter]
            
            // now use the sorted array
            self.waiters[sectionNumber] = sortedWaiterArray
         
            if self.isSearchBarActive() {
                // Search bar is active and the waiter name has been added
                // This invalidates the current search results so force a reload
                // when the search bar becomes inactive
                self.shouldReloadTable = true
            }
            else {
                // update the appropriate section of the table view
                self.tableView.reloadSections(IndexSet(integer: sectionNumber), with: animation)
            }
        }
    }
    
    internal func updateShifts(waiterTableInfo: WaiterTableInfo, atIndexPath indexPath: IndexPath, with animation: UITableViewRowAnimation) {
        self.tableView.reloadRows(at: [indexPath], with: animation)
    }
    
    internal func deleteShift(waiterTableInfo: WaiterTableInfo, atIndexPath indexPath: IndexPath, with animation: UITableViewRowAnimation) {
        self.tableView.reloadRows(at: [indexPath], with: animation)
    }
    
    // MARK: - UINavigationControllerDelegate

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadeTransitionAnimator()
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let destVC = segue.destination
        if segue.identifier == WaiterListViewController.SEGUE_WAITER_DETAIL {
            if destVC is WaiterDetailViewController {
                let waiterDetailVC = destVC as! WaiterDetailViewController
                waiterDetailVC.delegate = self
                
                if sender is IndexPath {
                    let indexPath: IndexPath = sender as! IndexPath

                    waiterDetailVC.waiterTableInfo = self.isSearchBarActive()
                        ? self.filteredWaiters[indexPath.row]
                        : WaiterTableInfo(origIndexPath: indexPath, waiter: self.waiters[indexPath.section][indexPath.row])
                    
                    waiterDetailVC.indexPath = indexPath
                }
            }
        }
    }
}
