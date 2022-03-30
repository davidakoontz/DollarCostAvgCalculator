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
    
    
    var percentageFormat: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        return formatter.string(from: self as NSNumber) ?? twoDecimalPlaceString
    }
    
    var currencyFormat: String {
        let formatter = NumberFormatter()
        formatter.locale =  Locale.current  // USA
        
        formatter.numberStyle =  .currency
        
        if let value = formatter.string(from: self as NSNumber) {
            return value
        } else {
            return twoDecimalPlaceString    // USA dollar.cents  default
        }
    }
    
    func toCurrencyFormat(hasDollarSymbol: Bool = true, hasDecimalPlaces:  Bool = true) -> String {
        let formatter = NumberFormatter()
        formatter.locale  =  Locale.current  // USA
        formatter.numberStyle = .currencyPlural
        
        if hasDollarSymbol == false {
            formatter.currencySymbol =  ""
        }
        if hasDecimalPlaces ==  false {
            formatter.maximumFractionDigits = 0
        }
        return  formatter.string(from: self as NSNumber) ?? twoDecimalPlaceString
    }
}
