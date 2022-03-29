//
//  AVService.swift
//  DollarCostAvgCalculator
//
//  Created by David on 3/24/22.
//

import Foundation
import Combine

struct AVService {
    
    enum APIServiceError: Error {
        case encoding
        case badRequest
    }
    
    let apiKey1 = "41UY1WI73RS730QQ"    // david@koontz.name
    let apiKey2 = "2VYP6T8EKZ86PDB7"    // davidakoontz@gmail.com
    let apiKey3 = "DK7TE9W6L2MSO3VV"    // cards.inspireme@gmail.com
    
    let apiKeys = ["41UY1WI73RS730QQ", "2VYP6T8EKZ86PDB7", "DK7TE9W6L2MSO3VV"]
    
    
    // computed property  - randomly  gets a limited key (limit 5  calls / min.)
    var API_KEY: String {
        return apiKeys.randomElement() ?? "41UY1WI73RS730QQ"
    }
    

    
    func fetchSymbolsPublisher(keywords:  String) -> AnyPublisher<SearchResults, Error> {
        //  keywords with  spaces crash because  of  encoding errors.
        guard let keywords = keywords.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return Fail(error: APIServiceError.encoding).eraseToAnyPublisher()
        }
        let urlString = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(keywords)&apikey=\(API_KEY)"
        guard let url = URL(string: urlString) else {
            return Fail(error: APIServiceError.badRequest).eraseToAnyPublisher()
        }
        
        // let url =  URL(string: urlString)!   // bad practice -  put  guard around it!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map({ $0.data })
            .decode(type: SearchResults.self, decoder: JSONDecoder() )
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
        
    }
    
    
    func fetchTimeSeriesMonthlyAdjustedPublisher(keywords:  String) -> AnyPublisher<TimeSeriesMonthlyAdjusted, Error> {
        //  keywords with  spaces crash because  of  encoding errors.
        guard let keywords = keywords.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return Fail(error: APIServiceError.encoding).eraseToAnyPublisher()
        }
        let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_MONTHLY_ADJUSTED&symbol=\(keywords)&apikey=\(API_KEY)"
        guard let url = URL(string: urlString) else {
            return Fail(error: APIServiceError.badRequest).eraseToAnyPublisher()
        }
        
        // let url =  URL(string: urlString)!   // bad practice -  put  guard around it!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map({ $0.data })
            .decode(type: TimeSeriesMonthlyAdjusted.self, decoder: JSONDecoder() )
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
        
    }
}

/*  lesson 21 attempt to resolve...
extension Publisher where Self.Failure ==  Never {
    // because the publisher can NEVER FAIL - by design!
    public  func sink(receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable { return AnyCancellable() -> Void }
}
 
 */
