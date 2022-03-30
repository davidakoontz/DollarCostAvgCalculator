//
//  CalcculatorPresenter.swift
//  DollarCostAvgCalculator
//
//  Created by David on 3/29/22.
//

import UIKit

struct CalculatorPresenter {
    
    func getPresentation(result: DCAResult) -> CalculatorPresentation {
        
        let isProfitable = result.isProfitable == true
        let gainSymbol = isProfitable ? "+" : ""
        
        return .init(currentValueLabelBackgroundColor: isProfitable ? .themeGreen : .themeRed,
                     currentValue: result.currentValue.currencyFormat,
                     investmentAmount: result.investmentAmount.toCurrencyFormat(hasDecimalPlaces: false),
                     gain: result.gain.toCurrencyFormat(hasDollarSymbol: true, hasDecimalPlaces: false).prefix(withText: gainSymbol),
                     yield: result.yield.percentageFormat.prefix(withText: gainSymbol).addParentheses(),
                     yieldLabelTextColor: isProfitable ? .systemGreen : .systemRed,
                     annualReturn: result.annualReturn.percentageFormat,
                     annualReturnLabelTextColor: isProfitable ? .systemGreen : .systemRed)
    }
}

struct CalculatorPresentation {
    let currentValueLabelBackgroundColor: UIColor
    let currentValue: String
    let investmentAmount: String
    let gain: String
    let yield: String
    let yieldLabelTextColor: UIColor
    let annualReturn: String
    let annualReturnLabelTextColor: UIColor
}
