//
//  WaiterDetailViewController.swift
//  ShiftTracker
//
//  Created by Crul on 2016-11-16.
//  Copyright © 2016 Sid. All rights reserved.
//

import UIKit

class WaiterDetailViewController: UITableViewController {

    // MARK: Constants
    
    static let CELL_ID_PROFILE: String = "waiterProfileCell"
    static let CELL_ID_SHIFT_DETAIL: String = "waiterShiftDetailCell"
    static let CELL_ID_DELETE: String = "waiterDeleteCell"
    
    static let SECTION_TITLE_PROFILE: String = "Profile"
    static let SECTION_TITLE_SHIFTS: String = "Shifts"
    static let SECTION_TITLE_EMPTY: String = ""
    
    static let ROW_TITLE_NAME: String = "Name"
    static let ROW_TITLE_DELETE: String = "Delete Waiter"
    static let ROW_TITLE_NEW_SHIFT: String = "Add New Shift"
    
    static let SECTION_PROFILE: Int = 0
    static let SECTION_SHIFTS: Int = 1
    static let SECTION_DELETE: Int = 2
    
    static let TAG_PROFILE_LABEL: Int = 1
    static let TAG_PROFILE_TEXT_FIELD: Int = 2
    
    // MARK: Members
    private var waiterShifts: [Shift] = []
    
    var delegate: WaiterUpdateDelegate? = nil
    var indexPath: IndexPath? = nil
    
    var waiter: Waiter? = nil {
        // property observer
        didSet {
            self.waiterShifts = self.waiter?.shifts?.sortedArray(using: [NSSortDescriptor(key: "startTime", ascending: true)]) as! [Shift]
        }
    }
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // MARK: Private Methods
    
    // MARK: Event Handlers
    
    @IBAction func didSaveWaiter(_ sender: Any) {
        if self.waiter == nil {
            // new waiter
            let nameTextField = self.tableView.viewWithTag(WaiterDetailViewController.TAG_PROFILE_TEXT_FIELD) as! UITextField
            
            if nameTextField.text! != "" {
                self.waiter = Waiter.createWaiter(name: nameTextField.text!)
                self.delegate?.add(waiter: self.waiter!)
                
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
        else {
            // updating waiter
        }
    }
    
    @objc private func textFieldDidChange(textField: UITextField) {
        self.saveButton.isEnabled = textField.text! != ""
    }
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.saveButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.waiter == nil {
            // Don't show the delete row when adding a new waiter
            return 2
        }
        
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case WaiterDetailViewController.SECTION_PROFILE:
            return 1
        case WaiterDetailViewController.SECTION_SHIFTS:
            // Add an extra row for the Add new shift button
            return 1 + self.waiterShifts.count
        case WaiterDetailViewController.SECTION_DELETE:
            return 1
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell?

        switch indexPath.section {
        case WaiterDetailViewController.SECTION_PROFILE:
            cell = tableView.dequeueReusableCell(withIdentifier: WaiterDetailViewController.CELL_ID_PROFILE, for: indexPath)
            
            let label = cell?.viewWithTag(WaiterDetailViewController.TAG_PROFILE_LABEL) as! UILabel
            label.text = WaiterDetailViewController.ROW_TITLE_NAME
            
            let textField = cell?.viewWithTag(WaiterDetailViewController.TAG_PROFILE_TEXT_FIELD) as! UITextField
            textField.autocapitalizationType = .words
            textField.text = self.waiter?.name!
            textField.addTarget(self, action:#selector(textFieldDidChange), for: UIControlEvents.editingChanged)
            
            self.saveButton.isEnabled = textField.text! != ""
            
            break
        case WaiterDetailViewController.SECTION_SHIFTS:
            cell = tableView.dequeueReusableCell(withIdentifier: WaiterDetailViewController.CELL_ID_SHIFT_DETAIL, for: indexPath)
            
            // First row of this section is for adding new shifts
            if indexPath.row == 0 {
                cell?.textLabel?.text = WaiterDetailViewController.ROW_TITLE_NEW_SHIFT
            }
            else {
                cell?.textLabel?.text = self.waiterShifts[indexPath.row - 1].description
            }
            
            break
        case WaiterDetailViewController.SECTION_DELETE:
            cell = tableView.dequeueReusableCell(withIdentifier: WaiterDetailViewController.CELL_ID_DELETE, for: indexPath)
            cell?.textLabel?.text = WaiterDetailViewController.ROW_TITLE_DELETE
            cell?.textLabel?.textColor = .red
            break
        default:
            cell = nil
        }
        
        return cell!
    }
    
    // MARK: Table View Section Methods
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case WaiterDetailViewController.SECTION_PROFILE:
            return WaiterDetailViewController.SECTION_TITLE_PROFILE
        case WaiterDetailViewController.SECTION_SHIFTS:
            return WaiterDetailViewController.SECTION_TITLE_SHIFTS
        case WaiterDetailViewController.SECTION_DELETE:
            return WaiterDetailViewController.SECTION_TITLE_EMPTY
        default:
            return WaiterDetailViewController.SECTION_TITLE_EMPTY
        }
    }
    
    // MARK: - Table View Delegate Methods
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch indexPath.section {
        case WaiterDetailViewController.SECTION_PROFILE:
            return nil
        case WaiterDetailViewController.SECTION_DELETE:
            if self.waiter == nil {
                return nil
            }
        default:
            break
        }
        
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case WaiterDetailViewController.SECTION_SHIFTS:
            // First row of this section is for adding new shifts
            if indexPath.row == 0 {
            }
            else {
                
            }
            break
        case WaiterDetailViewController.SECTION_DELETE:
            let alertController = UIAlertController(title: "Delete", message: "Are you sure that you want to delete this waiter?", preferredStyle: UIAlertControllerStyle.alert)
            let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive) { (result : UIAlertAction) -> Void in
                DispatchQueue.main.async(execute: { 
                    self.dismiss(animated: true, completion: nil)
                })
                DispatchQueue.main.async(execute: {
                    if self.waiter != nil && self.indexPath != nil {
                        self.delegate?.delete(waiter: self.waiter!, atIndexPath: self.indexPath!, with: UITableViewRowAnimation.none)
                    }
                    
                    _ = self.navigationController?.popViewController(animated: true)
                })
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                self.dismiss(animated: true, completion:nil)
            }
            
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            
            break
        default:
            break
        }
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
