//
//  ChartHandler.swift
//  SimpleStock
//
//  Created by Corey Pett on 4/18/17.
//  Copyright © 2017 Corey Pett. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

final class StockData {
    
    typealias fetchCompletion = (StockDataResult) -> Void
    
    /// Fetches chart information for a stock from the Yahoo API
    ///
    /// - Parameters:
    ///   - symbol: symbol of the stock
    ///   - timeRange: an enum defining how far back of data you want to fetch
    ///   - completion: if success = true, data will be returned else return error
    public func fetchStockChartFor(symbol: String,
                                   timeRange: ChartTimeRange,
                                   completion: @escaping (fetchCompletion)) {
        
        let url = self.chartUrlForRange(symbol: symbol, range: timeRange)
            
        Alamofire.request(url, method: .get, parameters: ["":""], encoding: URLEncoding.default, headers: nil).responseData { (response:DataResponse<Data>) in
            
            switch(response.result) {
                
            case .success(_):
                
                // Dissect the data result as AlamoFire does not allow JSON response for this call?
                guard let result = response.result.value else {
                    completion(.Failure(.JSONError)); return
                }
                
                // Trim off some string fat
                var jsonString = NSString(data: result, encoding: String.Encoding.utf8.rawValue)!
                jsonString = jsonString.substring(from: 30) as NSString
                jsonString = jsonString.substring(to: jsonString.length-1) as NSString
                
                guard
                    let data = jsonString.data(using: String.Encoding.utf8.rawValue),
                    let resultJSON = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String : AnyObject],
                    let series = resultJSON?["series"] as? [ [String : AnyObject] ]
                else {
                    completion(.Failure(.JSONError)); return
                }
                
                // Success
                completion(.Success(series)); return
                
            case .failure(_):
                completion(.Failure(.FetchError));
                break
            }
        }
    }
}

extension StockData {
    
    typealias completion = (StockDataResult) -> Void
    
    /// Takes an array of a stockPoint dictionary and sets a relationship between the stock and stockPoints
    ///
    /// - Parameters:
    ///   - stock: the stock you was to associate with the data points
    ///   - data: the stock points
    ///   - completion: if success = true, the stock will hold the data points else return error
    public func saveStockChartTo(stock: Stock,
                                 data: [[String: AnyObject]],
                                 completion: @escaping (completion)) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            completion(.Failure(.SaveError)); return
        }
        
        appDelegate.persistentContainer.performBackgroundTask ({ (managedContext) in
            
            // Allow saving for different contexts
            guard let stock = managedContext.object(with: stock.objectID) as? Stock else {
                completion(.Failure(.SaveError)); return
            }
            
            // Remove old points
            if stock.points?.count != 0 {
                stock.removeFromPoints(stock.points!)
            }
            
            // Add new points
            for point in data {
                
                let _ = StockPoint.init(data: point, owner: stock, managedContext: managedContext)
                
                do {
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                    completion(.Failure(.SaveError)); return
                }
            }
            
            completion(.Success(nil))
        })
    }
    
    /// Handles fetching stockPoint data and saving it to a stock
    ///
    /// - Parameters:
    ///   - stock: the stock you was to associate with the data points
    ///   - timeRange: an enum defining how far back of data you want to fetch
    ///   - completion: if success = true, the stock will hold the data points else return error
    public func updateStockPoints(stock: Stock,
                                  timeRange: ChartTimeRange,
                                  completion: @escaping (completion)) {
        
        // Need symbol to find stock
        guard let symbol = stock.symbol else {
            completion(.Failure(.SaveError)); return
        }
        
        // Fetch stock's chart information from symbol
        self.fetchStockChartFor(symbol: symbol,
                                timeRange: .OneMonth) { (result) in
            
            switch result {
                
            // If successfully fetch data
            case .Success(let data):
                
                guard let data = data else {
                    completion(.Failure(.SaveError)); return
                }
                
                // Save newly fetched stock data
                self.saveStockChartTo(stock: stock,
                                      data: data,
                                      completion: { (result) in
                    
                    switch result {
                        
                    case .Success(_):
                        completion(.Success(nil)); break
                    case .Failure(let error):
                        completion(.Failure(error)); break
                    }
                })
                
                return

            // Failed fetching data
            case .Failure(let error):
                completion(.Failure(error)); break
            }
        }
    }
}


// MARK: - Private Functions

fileprivate extension StockData {
    
    
    /// Helper function to return the correct Yahoo API URL
    ///
    /// - Parameters:
    ///   - symbol: symbol of the stock you want to retrieve from API
    ///   - range: an enum defining how far back of data you want to fetch
    /// - Returns: yahoo API URL
    func chartUrlForRange(symbol: String, range: ChartTimeRange) -> String {
        
        var timeString = String()
        
        switch (range) {
            
        case .OneDay:
            timeString = "1d"
        case .FiveDays:
            timeString = "5d"
        case .TenDays:
            timeString = "10d"
        case .OneMonth:
            timeString = "1m"
        }
        
        return "http://chartapi.finance.yahoo.com/instrument/1.0/\(symbol)/chartdata;type=quote;range=\(timeString)/json"
    }
}

// MARK: - Public enums

public enum ChartTimeRange {
    case OneDay, FiveDays, TenDays, OneMonth
}

public enum StockDataResult {
    case Success([[String : AnyObject]]?)
    case Failure(StockDataError)
}

public enum StockDataError: Error {
    case FetchError
    case SaveError
    case JSONError
    
    var alert: UIAlertController! {
        
        let title = "Uh Oh! Error!"
        var message = String()
        
        switch self {
            
        case .JSONError:
            message = "Try a different stock, the format returned causes an error with JSONSerialization"
            
        default:
            message = "Please reconnect to the internet. There isn't any saved data for your stock choice"
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OKAY", style: .default, handler: nil)
        
        alert.addAction(okAction)
        
        return alert
    }
}
