//
//  DCAService.swift
//  DollarCostAvgCalculator
//
//  Created by David on 3/27/22.
//

import Foundation

struct DCAService {
    
    func calculate(asset: Asset, initialInvestmentAmount: Double,
                   monthlyDCAAmount: Double,
                   initialDateOfInvestmentIndex: Int) -> DCAResult {
        
        let investmentAmount = getInvestmentAmount(initialInvestmentAmount:
                                                    initialInvestmentAmount, monthlyDCAAmount: monthlyDCAAmount, initialDateOfInvestmentIndex: initialDateOfInvestmentIndex)
        
        let latestSharePrice = getLatestSharePrice(asset: asset)
        let numberOfShares = getNumberOfShares(asset: asset,
                                               initialInvestmentAmount: initialInvestmentAmount,
                                               monthlyDCAAmount: monthlyDCAAmount,
                                               initialDateOfInvestmentIndex: initialDateOfInvestmentIndex)
        let currentValue = getCurrentValue(numberOfShares: numberOfShares, latestSharePrice: latestSharePrice)
        
        let isProfitable =  currentValue > investmentAmount
        
        return  .init(currentValue: currentValue,               // DCAResult.init
                      investmentAmount: investmentAmount,
                      gain: 0, yield: 0, annualReturn: 0, isProfitable: isProfitable )
    }
    
    private  func getInvestmentAmount(initialInvestmentAmount: Double,
                                      monthlyDCAAmount:  Double,
                                      initialDateOfInvestmentIndex: Int) -> Double {
        
        var totalAmount = Double()
        totalAmount += initialInvestmentAmount
        //  number of months *  monthly amount
        let sumDCAAmount = initialDateOfInvestmentIndex.doubleValue * monthlyDCAAmount
        // add to total
        totalAmount += sumDCAAmount
        
        return totalAmount
    }
    
    private func getCurrentValue(numberOfShares: Double, latestSharePrice: Double) -> Double {
        return numberOfShares * latestSharePrice
    }
    
    private func getLatestSharePrice(asset: Asset) -> Double {
        let latestPrice = asset.timeSeriesMonthlyAdjusted.getMonths().first?.adjustedClose ?? 0
        return latestPrice
    }
    
    private func getNumberOfShares(asset: Asset, initialInvestmentAmount: Double,
                                   monthlyDCAAmount: Double,
                                   initialDateOfInvestmentIndex: Int) -> Double {
        
        var totalShares = Double()
        let initialInvestmentOpenPrice = asset.timeSeriesMonthlyAdjusted.getMonths()[initialDateOfInvestmentIndex].adjustedOpen
        let initialShares = initialInvestmentAmount / initialInvestmentAmount   // we don't truncate to whole shares yet
        
        totalShares += initialShares
        asset.timeSeriesMonthlyAdjusted.getMonths().prefix(initialDateOfInvestmentIndex).forEach { (monthInfo) in
            let DCAShares = monthlyDCAAmount / monthInfo.adjustedOpen
            totalShares += DCAShares
        }
        return totalShares
    }
}

struct DCAResult {
    let currentValue: Double
    let investmentAmount: Double
    let gain: Double
    let yield: Double
    let annualReturn: Double
    let isProfitable: Bool
}
