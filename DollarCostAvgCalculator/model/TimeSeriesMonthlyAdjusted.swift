//
//  TimeSeriesMonthlyAdjusted.swift
//  DollarCostAvgCalculator
//
//  Created by David on 3/26/22.
//

import Foundation

struct MonthInfo {
    let date: Date
    let adjustedOpen: Double
    let adjustedClose: Double
}

struct TimeSeriesMonthlyAdjusted: Decodable {
    let meta: Meta
    let timeSeries: [String: OHLC]      // unsorted hash table
    
    enum CodingKeys: String, CodingKey {
        case meta =  "Meta Data"
        case timeSeries = "Monthly Adjusted Time Series"
    }

    func getMonths() -> [MonthInfo] {
        var montharray: [MonthInfo]  = []
        let sortedTimeSeries = timeSeries.sorted(by: { $0.key > $1.key } )
        
        for (dateString, ohlc)  in sortedTimeSeries {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            guard let date = dateFormatter.date(from: dateString),
                  let adjustedOpen = Double(ohlc.open),
                  let adjustedClose = Double(ohlc.adjustedClose) else { return  [] }
            let monthInfo = MonthInfo(date: date, adjustedOpen: adjustedOpen, adjustedClose: adjustedClose)
            montharray.append(monthInfo)
        }
      
        return montharray // array sorted by date
    }
}


struct Meta: Decodable {
    
    let symbol: String
    
    enum CodingKeys: String, CodingKey {
        case symbol =  "2. Symbol"
    }
}


struct OHLC: Decodable {

    let open: String
    let close: String
    let adjustedClose: String
    
    enum CodingKeys: String, CodingKey  {
        case open =  "1. open"
        case close =  "4. close"
        case adjustedClose = "5. adjusted close"
    }
}

/*
// From  AV https://www.alphavantage.co/query?function=TIME_SERIES_MONTHLY_ADJUSTED&symbol=IBM&apikey=demo
//{
//    "Meta Data": {
//        "1. Information": "Monthly Adjusted Prices and Volumes",
//        "2. Symbol": "IBM",
//        "3. Last Refreshed": "2022-03-25",
//        "4. Time Zone": "US/Eastern"
//    },
//    "Monthly Adjusted Time Series": {
//        "2022-03-25": {
//            "1. open": "122.6700",
//            "2. high": "131.4000",
//            "3. low": "120.7000",
//            "4. close": "131.3500",
//            "5. adjusted close": "131.3500",
//            "6. volume": "81275797",
//            "7. dividend amount": "0.0000"
//        },
//        "2022-02-28": {
//            "1. open": "133.7600",
//            "2. high": "138.8200",
//            "3. low": "118.8100",
//            "4. close": "122.5100",
//            "5. adjusted close": "122.5100",
//            "6. volume": "98492968",
//            "7. dividend amount": "1.6400"
//        },
*/
