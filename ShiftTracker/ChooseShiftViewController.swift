//
//  ChooseShiftViewController.swift
//  ShiftTracker
//
//  Created by Sid on 2016-11-17.
//  Copyright © 2016 Sid. All rights reserved.
//

import UIKit

// Use this struct to set/get Shift data
// in UIKit code instead of the Core Data Shift class
// This is because we want to maintain the data integrity
// of the Core Data class as at any given time within the code
// for this VC, one or both of the date attributes might be nil
struct ShiftData {
    static let DATE_FORMAT = "MMM d h:mma"
    static let DATE_FORMAT_TIME_ONLY = "h:mma"
    
    var startTime: Date?
    var endTime: Date?
    
    func description() -> String {
        if self.startTime != nil && self.endTime != nil {
            if DateHelper.datesAreOnSameDay(date1: self.startTime!, date2: self.endTime!) {
                return "\(DateHelper.stringFromDate(date: self.startTime!, withDateFormat: ShiftData.DATE_FORMAT)) to \(DateHelper.stringFromDate(date: self.endTime!, withDateFormat: ShiftData.DATE_FORMAT_TIME_ONLY))"
            }
            
            return "\(DateHelper.stringFromDate(date: self.startTime!, withDateFormat: ShiftData.DATE_FORMAT)) to \(DateHelper.stringFromDate(date: self.endTime!, withDateFormat: ShiftData.DATE_FORMAT))"
        }
        else if self.startTime != nil && self.endTime == nil {
            return "\(DateHelper.stringFromDate(date: self.startTime!, withDateFormat: ShiftData.DATE_FORMAT)) to ..."
        }
        else if self.startTime == nil && self.endTime != nil {
            return "... to \(DateHelper.stringFromDate(date: self.endTime!, withDateFormat: ShiftData.DATE_FORMAT))"
        }
        else {
            return ChooseShiftViewController.SELECT_SHIFT
        }
    }
}

class ChooseShiftCell: UITableViewCell {
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Set background color here because using the UIAppearance class doesn't
        // work as expected for when multiselection is on
        let view = UIView()
        view.backgroundColor = StyleManager.themeColor
        selectedBackgroundView = view
    }
}

class ChooseShiftViewController: UITableViewController {
    // MARK: Constants
    
    static let SELECT_SHIFT: String = "Select Shift Start Time"
    static let CELL_ID_SHIFT_TIME: String = "shiftTimeCell"
    
    static let TAG_TABLE_CELL_LABEL: Int = 1
    static let WEEKS_FROM_NOW: Int = 2
    
    static let LABEL_SCALE_FACTOR: CGFloat = 0.5
    
    // MARK: Members

    var shiftData: ShiftData?
    var indexPath: IndexPath?
    var delegate: ShiftUpdateDelegate? = nil
    
    private var totalDates: [Date] = []
    private var scrollToRow: Int = 0
    private var rowsToSelect: [Int] = []
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // MARK: Private Methods
    
    private func setupTotalDates() {
        let userCalender = Calendar.current
        let now = userCalender.startOfDay(for: Date())
        let past = userCalender.date(byAdding: .weekOfYear, value: -ChooseShiftViewController.WEEKS_FROM_NOW, to: now)
        let future = userCalender.date(byAdding: .weekOfYear, value: ChooseShiftViewController.WEEKS_FROM_NOW, to: now)
        
        let hoursBetweenPastFuture: DateComponents = userCalender.dateComponents([.hour], from: past!, to: future!)
        
        self.totalDates = []
        var curDate: Date = past!
        
        for idx in 0..<hoursBetweenPastFuture.hour! {
            self.totalDates.append(curDate)
            
            if self.shiftData != nil {
                if curDate == self.shiftData?.startTime {
                    self.scrollToRow = idx
                    self.rowsToSelect.append(idx)
                }
                else if curDate == self.shiftData?.endTime {
                    self.rowsToSelect.append(idx)
                }
            }
            else if (curDate == now) {
                // scroll to the current date
                self.scrollToRow = idx
            }
            
            curDate = userCalender.date(byAdding: .hour, value: 1, to: curDate)!
        }
    }
    
    private func swapStartAndEndTime(shiftData: inout ShiftData?) {
        let tmpTime = shiftData?.startTime
        shiftData?.startTime = shiftData?.endTime
        shiftData?.endTime = tmpTime
    }
    
    // MARK: Event Handlers
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func didTapSaveButton(_ sender: Any) {
        if self.shiftData != nil && self.shiftData?.startTime != nil && self.shiftData?.endTime != nil {
            if self.indexPath == nil && (self.shiftData?.startTime)! < (self.shiftData?.endTime)! {
                self.delegate?.addShift(shiftData: self.shiftData!, with: .none)
            }
            else if (self.shiftData?.startTime)! < (self.shiftData?.endTime)! {
                self.delegate?.updateShift(shiftData: self.shiftData!, atIndexPath: self.indexPath!, with: .none)
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }

    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.allowsMultipleSelection = true
        
        self.setupTotalDates()
        
        if self.shiftData == nil {
            self.title = ChooseShiftViewController.SELECT_SHIFT
            self.saveButton.isEnabled = false
        }
        else {
            self.shiftData = ShiftData(startTime: self.shiftData?.startTime, endTime: self.shiftData?.endTime)
            self.title = self.shiftData?.description()
        }
        
        // the navigationTitleView will get resized automatically
        let navigationTitleView = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        navigationTitleView.backgroundColor = .clear
        navigationTitleView.textAlignment = .center
        navigationTitleView.adjustsFontSizeToFitWidth = true
        navigationTitleView.minimumScaleFactor = ChooseShiftViewController.LABEL_SCALE_FACTOR
        navigationTitleView.text = self.title
        
        self.navigationController?.navigationBar.topItem?.titleView = navigationTitleView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        for row: Int in self.rowsToSelect {
          self.tableView.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: UITableViewScrollPosition.none)
        }
        self.tableView.scrollToRow(at: IndexPath(row: self.scrollToRow, section: 0), at: .top, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.view.hideToolTip()
    }

    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.totalDates.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChooseShiftViewController.CELL_ID_SHIFT_TIME, for: indexPath)
        cell.selectionStyle = .blue
        
        let label = cell.viewWithTag(ChooseShiftViewController.TAG_TABLE_CELL_LABEL) as! UILabel
        label.text = DateHelper.stringFromDate(date: self.totalDates[indexPath.row] as NSDate, withDateFormat: ShiftData.DATE_FORMAT)
        
        return cell
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.saveButton.isEnabled = false
        
        let dateDeselected = self.totalDates[indexPath.row]
        if dateDeselected == self.shiftData?.startTime {
           self.shiftData?.startTime = nil
        }
        else if dateDeselected == self.shiftData?.endTime {
            self.shiftData?.endTime = nil
        }
        
        (self.navigationController?.navigationBar.topItem?.titleView as! UILabel).text = self.shiftData?.description()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.saveButton.isEnabled = false
        
        if self.shiftData == nil || (self.shiftData?.startTime == nil && self.shiftData?.endTime == nil) {
            self.shiftData = ShiftData(startTime: self.totalDates[indexPath.row], endTime: nil)

            // since self.view is a subclass of UIScrollView getting views to stick to the bottom is difficult
            // Thus we will use the navigation controller's view
            self.navigationController?.view.showToolTip("Now select a shift end time")
        }
        else {
            if self.shiftData?.startTime != nil && self.shiftData?.endTime == nil {
                self.shiftData?.endTime = self.totalDates[indexPath.row]
                
                // swap start and end times if end time is before start time
                if (self.shiftData?.endTime)! < (self.shiftData?.startTime)! {
                    // pass by reference
                    self.swapStartAndEndTime(shiftData: &self.shiftData)
                }
                
                self.saveButton.isEnabled = true
            }
            else if self.shiftData?.startTime == nil && self.shiftData?.endTime != nil {
                self.shiftData?.startTime = self.totalDates[indexPath.row]
                
                // swap start and end times if end time is before start time
                if (self.shiftData?.endTime)! < (self.shiftData?.startTime)! {
                    // pass by reference
                    self.swapStartAndEndTime(shiftData: &self.shiftData)
                }
                
                self.saveButton.isEnabled = true
            }
            else if self.shiftData?.startTime != nil && self.shiftData?.endTime != nil {
                self.shiftData?.startTime = self.totalDates[indexPath.row]
                self.shiftData?.endTime = nil
                
                let indexPathsOfVisibleRows: [IndexPath] = tableView.indexPathsForVisibleRows!
                for curIndexPath in tableView.indexPathsForSelectedRows! {
                    // don't deselect this newly selected row
                    if curIndexPath == indexPath {
                        continue
                    }
                    
                    if indexPathsOfVisibleRows.contains(curIndexPath) {
                        tableView.deselectRow(at: curIndexPath, animated: true)
                    }
                    else {
                        tableView.deselectRow(at: curIndexPath, animated: false)
                    }
                    
                }
            }
        }
        
        (self.navigationController?.navigationBar.topItem?.titleView as! UILabel).text = self.shiftData?.description()
    }
}
