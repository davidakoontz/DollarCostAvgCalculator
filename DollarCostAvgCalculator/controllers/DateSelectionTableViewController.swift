//
//  DateViewTableController.swift
//  DollarCostAvgCalculator
//
//  Created by David on 3/26/22.
//

import Foundation
import UIKit

class DateSelectionTableViewController:   UITableViewController {
    
    private var months:  [MonthInfo] = []
    var timeSeriesMonthlyAdjusted: TimeSeriesMonthlyAdjusted?
    var didSelectDate: ((Int) -> Void)?         // a closure
    var selectedIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupMonths()
    }
    
    private func setupNavigation() {
        title = "Select Date"
    }
    
    private func setupMonths() {
        months = timeSeriesMonthlyAdjusted?.getMonths() ?? []
    }
}

extension DateSelectionTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeSeriesMonthlyAdjusted?.getMonths().count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "dateTableViewCell", for: indexPath) as! DateSelectionTableViewCell
        let index = indexPath.item
        let months = months[index]
        let isSelected =  (index ==  selectedIndex )     // add checkmark
        
        cell.configure(with: months, index: index, isSelected: isSelected)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectDate?(indexPath.item)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}

class DateSelectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var monthsAgoLabel: UILabel!
    
    fileprivate func calcMonthsAgo(_ index: Int) {
       
        if index == 1 {
            monthsAgoLabel.text = "1 month ago"
        } else if index > 1 {
            monthsAgoLabel.text = "\(index) months ago"
        } else {
            monthsAgoLabel.text = "Recently invested"
        }
    }
    
    func configure(with months:  MonthInfo, index: Int, isSelected: Bool) {
        monthLabel.text =  months.date.MMMMYYYYFormat        // computed property  e.g. December  2022
        
        // add checkmark to item
        accessoryType = isSelected ? .checkmark   : .none
        
        calcMonthsAgo(index)
        
        
    }
}
