//
//  WaiterDetailViewController.swift
//  ShiftTracker
//
//  Created by Crul on 2016-11-16.
//  Copyright © 2016 Sid. All rights reserved.
//

import UIKit

protocol ShiftUpdateDelegate {
    func addShift(shiftData: ShiftData, with animation: UITableViewRowAnimation)
    func updateShift(shiftData: ShiftData, atIndexPath indexPath: IndexPath, with animation: UITableViewRowAnimation)
}

class WaiterDetailViewController: UITableViewController, ShiftUpdateDelegate {
    // MARK: Constants
    
    static let SEGUE_CHOOSE_SHIFT: String = "chooseShiftSegue"
    
    static let CELL_ID_PROFILE: String = "waiterProfileCell"
    static let CELL_ID_SHIFT_DETAIL: String = "waiterShiftDetailCell"
    static let CELL_ID_ADD_SHIFT: String = "waiterAddNewShiftCell"
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
    static let TAG_ADD_SHIFT_IMG: Int = 3
    static let TAG_ADD_SHIFT_LABEL: Int = 4
    
    // MARK: Members
    
    private var waiterShifts: [Shift] = []
    private var shouldShowSwipeToDelToolTip = false
    
    var delegate: WaiterUpdateDelegate? = nil
    var indexPath: IndexPath? = nil
    
    var waiterTableInfo: WaiterTableInfo? = nil {
        // property observer
        didSet {
            self.waiterShifts = self.waiterTableInfo?.waiter.shifts?.sortedArray(using: [NSSortDescriptor(key: "startTime", ascending: true)]) as! [Shift]
        }
    }
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // MARK: Private Methods
    
    private func getShiftRow(indexPath: IndexPath) -> Int {
        return indexPath.row - 1
    }
    
    private func getShiftAt(indexPath: IndexPath) -> Shift {
        // the - 1 compensates for the Add New Shift row
        return self.waiterShifts[self.getShiftRow(indexPath: indexPath)]
    }
    
    // MARK: Event Handlers
    
    @IBAction func didSaveWaiter(_ sender: Any) {
        let nameTextField = self.tableView.viewWithTag(WaiterDetailViewController.TAG_PROFILE_TEXT_FIELD) as! UITextField
        
        if self.waiterTableInfo == nil {
            // Adding new waiter
            if nameTextField.text! != "" {
                self.waiterTableInfo = WaiterTableInfo(origIndexPath: nil,
                                                              waiter: Waiter.createWaiter(name: nameTextField.text!.trimmingCharacters(in: CharacterSet.whitespaces)))
                self.delegate?.add(waiterTableInfo: self.waiterTableInfo!, with: UITableViewRowAnimation.none)
                
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
        else {
            // Updating existing waiter
            if nameTextField.text! != "" && self.indexPath != nil {
                self.waiterTableInfo?.waiter.name = nameTextField.text!.trimmingCharacters(in: CharacterSet.whitespaces)
                self.delegate?.update(waiterTableInfo: self.waiterTableInfo!, atIndexPath: self.indexPath!, with: UITableViewRowAnimation.none)
                
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc private func textFieldDidChange(textField: UITextField) {
        self.saveButton.isEnabled = textField.text! != ""
    }
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.saveButton.isEnabled = false
        self.shouldShowSwipeToDelToolTip = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // since self.view is a subclass of UIScrollView getting views to stick to the bottom is difficult
        // Thus we will use the navigation controller's view
        if self.waiterShifts.count > 0 && self.shouldShowSwipeToDelToolTip {
            self.shouldShowSwipeToDelToolTip = false
            self.navigationController?.view.showToolTip("Swipe left on a shift to delete it")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.view.hideToolTip()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.waiterTableInfo == nil {
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
            textField.text = self.waiterTableInfo?.waiter.name!
            textField.addTarget(self, action:#selector(textFieldDidChange), for: UIControlEvents.editingChanged)
            
            self.saveButton.isEnabled = textField.text! != ""
            
            break
        case WaiterDetailViewController.SECTION_SHIFTS:
            // First row of this section is for adding new shifts
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: WaiterDetailViewController.CELL_ID_ADD_SHIFT, for: indexPath)
                
                let imageView = cell?.viewWithTag(WaiterDetailViewController.TAG_ADD_SHIFT_IMG) as! UIImageView
                imageView.image = imageView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                imageView.tintColor = StyleManager.themeColor
                
                let label = cell?.viewWithTag(WaiterDetailViewController.TAG_ADD_SHIFT_LABEL) as! UILabel
                label.textColor = StyleManager.themeColor
                label.text = WaiterDetailViewController.ROW_TITLE_NEW_SHIFT
                label.font = label.font.bold()
            }
            else {
                let shift: Shift = self.getShiftAt(indexPath: indexPath)
                let shiftData = ShiftData(startTime: (shift.startTime as! Date), endTime: (shift.endTime as! Date))
                
                cell = tableView.dequeueReusableCell(withIdentifier: WaiterDetailViewController.CELL_ID_SHIFT_DETAIL, for: indexPath)
                cell?.textLabel?.text = shiftData.description()
                
                cell?.textLabel?.adjustsFontSizeToFitWidth = true
                cell?.textLabel?.minimumScaleFactor = WaiterListViewController.LABEL_SCALE_FACTOR
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            // Get the shift to delete
            let shift = self.getShiftAt(indexPath: indexPath)
            
            // Remove it from in-memory data array
            self.waiterShifts.remove(at: self.getShiftRow(indexPath: indexPath))
            
            // Update Core Data
            self.waiterTableInfo?.waiter.deleteShift(shift: shift)
            
            // Update table view
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // Let delegate know that a shift has been deleted
            self.delegate?.deleteShift(waiterTableInfo: self.waiterTableInfo!, atIndexPath: self.indexPath!, with: .none)
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch indexPath.section {
        case WaiterDetailViewController.SECTION_PROFILE:
            return nil
        case WaiterDetailViewController.SECTION_SHIFTS:
            // Don't allow a new shift to be created before the Waiter
            // object has been initialized
            if indexPath.row == 0 && self.waiterTableInfo == nil {
                if self.navigationController?.view.viewWithTag(UIView.TAG_TOOL_TIP) == nil {
                    debugPrint("queued tool tip")
                    self.navigationController?.view.showToolTip("Please choose a name and press save before creating a shift")
                }
                else {
                    debugPrint("Already showing tool tip")
                }
                
                return nil
            }
        case WaiterDetailViewController.SECTION_DELETE:
            if self.waiterTableInfo == nil {
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
                self.performSegue(withIdentifier: WaiterDetailViewController.SEGUE_CHOOSE_SHIFT, sender: self)
            }
            else {
                self.performSegue(withIdentifier: WaiterDetailViewController.SEGUE_CHOOSE_SHIFT, sender: indexPath)
            }
            
            break
        case WaiterDetailViewController.SECTION_DELETE:
            let alertController = UIAlertController(title: "Delete", message: "Are you sure that you want to delete this waiter?", preferredStyle: UIAlertControllerStyle.alert)
            let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive) { (result : UIAlertAction) -> Void in
                DispatchQueue.main.async(execute: { 
                    self.dismiss(animated: true, completion: nil)
                })
                DispatchQueue.main.async(execute: {
                    if self.waiterTableInfo != nil && self.indexPath != nil {
                        self.delegate?.delete(waiterTableInfo: self.waiterTableInfo!, atIndexPath: self.indexPath!, with: UITableViewRowAnimation.none)
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
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: WaiterUpdateDelegate Delegate Methods
    
    internal func updateShift(shiftData: ShiftData, atIndexPath indexPath: IndexPath, with animation: UITableViewRowAnimation) {
        let shift = self.getShiftAt(indexPath: indexPath)
        shift.startTime = shiftData.startTime as NSDate?
        shift.endTime = shiftData.endTime as NSDate?
        
        self.tableView.reloadRows(at: [indexPath], with: animation)
    }
    
    internal func addShift(shiftData: ShiftData, with animation: UITableViewRowAnimation) {
        let newShift = Shift.createShift(start: shiftData.startTime, end: shiftData.endTime)
        self.waiterTableInfo?.waiter.addToShifts(newShift)
        
        self.waiterShifts.append(newShift)
        
        self.tableView.insertRows(at: [IndexPath(row: self.waiterShifts.count, section: WaiterDetailViewController.SECTION_SHIFTS)], with: animation)
        self.delegate?.updateShifts(waiterTableInfo: self.waiterTableInfo!, atIndexPath: self.indexPath!, with: animation)
        
        self.shouldShowSwipeToDelToolTip = true
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        var destVC = segue.destination
        if destVC is UINavigationController {
           destVC = (destVC as! UINavigationController).viewControllers.first!
        }
        
        if segue.identifier == WaiterDetailViewController.SEGUE_CHOOSE_SHIFT {
            if destVC is ChooseShiftViewController {
                let chooseShiftVC = destVC as! ChooseShiftViewController
                chooseShiftVC.delegate = self
                
                if sender is IndexPath {
                    let indexPath: IndexPath = sender as! IndexPath
                    let shift: Shift = self.getShiftAt(indexPath: indexPath)
                    
                    chooseShiftVC.shiftData = ShiftData(startTime: (shift.startTime as! Date), endTime: (shift.endTime as! Date))
                    chooseShiftVC.indexPath = indexPath
                }
            }
        }
    }
}
