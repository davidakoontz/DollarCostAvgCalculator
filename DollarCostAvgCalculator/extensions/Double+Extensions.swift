//
//  Double+Extensions.swift
//  DollarCostAvgCalculator
//
//  Created by David on 3/27/22.
//

import Foundation

extension Double {
    
    var stringValue: String {
        return String(describing: self)
    }
    
    var twoDecimalPlaceString: String {
        return String(format: "%.2f", self)
    }
}
