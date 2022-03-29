//
//  Date+extension.swift
//  DollarCostAvgCalculator
//
//  Created by David on 3/26/22.
//

import Foundation

extension Date {
    
    var MMMMYYYYFormat: String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MMMM yyyy"
        return dateFormater.string(from: self)
    }
}
