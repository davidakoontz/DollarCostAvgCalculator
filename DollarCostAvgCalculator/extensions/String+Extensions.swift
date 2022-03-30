//
//  String+Extensions.swift
//  DollarCostAvgCalculator
//
//  Created by David on 3/26/22.
//

import Foundation

extension String {
    
    func addParentheses() -> String {
        return "(\(self))"       // add parentheses (not Brackets []) to the string
    }
    
    
    func prefix(withText text: String) -> String {
        return text + self
    }
    
    func toDouble() -> Double? {
        return Double(self)
    }
    
}
