//
//  ChooseShiftViewController.swift
//  ShiftTracker
//
//  Created by Crul on 2016-11-17.
//  Copyright © 2016 Sid. All rights reserved.
//

import UIKit

class ChooseShiftViewController: UITableViewController {

    // MARK: Constants
    
    static let CELL_ID_SHIFT_TIME: String = "shiftTimeCell"
    
    static let TAG_TABLE_CELL_LABEL: Int = 1
    static let WEEKS_FROM_NOW: Int = 2
    
    static let LABEL_SCALE_FACTOR: CGFloat = 0.5
    
    // MARK: Members

    var shift: Shift?
    var indexPath: IndexPath?
    var delegate: WaiterUpdateDelegate? = nil
    
    private var totalDates: [Date] = []
    private var scrollToRow: Int = 0
    
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
            
            if self.shift != nil {
                if curDate == (self.shift?.startTime as! Date) {
                    self.scrollToRow = idx
                }
            }
            else if (curDate == now) {
                // scroll to the current date
                self.scrollToRow = idx
            }
            
            curDate = userCalender.date(byAdding: .hour, value: 1, to: curDate)!
        }
    }
    
    // MARK: Event Handlers
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func didTapSaveButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.setupTotalDates()
        
        if self.shift == nil {
            self.title = "Select a Shift"
        }
        else {
            self.title = self.shift?.description
        }
        
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
    
        self.tableView.scrollToRow(at: IndexPath(row: self.scrollToRow, section: 0), at: .top, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        let label = cell.viewWithTag(ChooseShiftViewController.TAG_TABLE_CELL_LABEL) as! UILabel
        label.text = DateHelper.stringFromDate(date: self.totalDates[indexPath.row] as NSDate, withDateFormat: Shift.DATE_FORMAT)
        
        return cell
    }
    
}
