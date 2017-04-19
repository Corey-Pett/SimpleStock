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

public enum ChartTimeRange {
    case OneDay, FiveDays, TenDays, OneMonth
}

public enum StockDataError: Error {
    case FetchError
    case SaveError
}

fileprivate enum ChartKey: String {
    case volume, open, close, low, high
}

final class StockData {
    
    /// Fetches chart information for a stock from the Yahoo API
    ///
    /// - Parameters:
    ///   - symbol: symbol of the stock
    ///   - timeRange: an enum defining how far back of data you want to fetch
    ///   - completion: if success = true, data will be returned else return error
    public func fetchStockChartFor(symbol: String,
                                   timeRange: ChartTimeRange,
                                   completion: @escaping (Bool, [[String: AnyObject]]?, StockDataError?) -> Void) {
     
        DispatchQueue.global(qos: .background).async {
            
            let url = self.chartUrlForRange(symbol: symbol, range: timeRange)
                
            Alamofire.request(url, method: .get, parameters: ["":""], encoding: URLEncoding.default, headers: nil).responseData { (response:DataResponse<Data>) in
                
                switch(response.result) {
                    
                case .success(_):
                    
                    // Dissect the data result as AlamoFire does not allow JSON response for this call?
                    guard let result = response.result.value else {
                        completion(false, nil, StockDataError.FetchError); return
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
                        completion(false, nil, StockDataError.FetchError); return
                    }
                    
                    completion(true, series, nil)
                    
                    break
                    
                case .failure(_):
                    completion(false, nil, StockDataError.FetchError)
                    break
                }
            }
        }
    }
}

extension StockData {
    
    /// Takes an array of a stockPoint dictionary and sets a relationship between the stock and stockPoints
    ///
    /// - Parameters:
    ///   - stock: the stock you was to associate with the data points
    ///   - data: the stock points
    ///   - completion: if success = true, the stock will hold the data points else return error
    public func saveStockChartTo(stock: Stock,
                                 data: [[String: AnyObject]],
                                 completion: @escaping (Bool, StockDataError?) -> Void) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            completion(false, StockDataError.SaveError); return
        }
        
        appDelegate.persistentContainer.performBackgroundTask ({ (managedContext) in
            
            // Allow saving for different contexts
            guard let stock = managedContext.object(with: stock.objectID) as? Stock else {
                completion(false, StockDataError.SaveError); return
            }
            
            // Remove old points
            if stock.points?.count != 0 {
                stock.removeFromPoints(stock.points!)
            }
            
            // Add new points
            for point in data {
                
                let date = NSDate(timeIntervalSince1970: (point["Timestamp"] as? Double ?? point["Date"] as! Double))
                
                let stockPoint = StockPoint(entity: StockPoint.entity(), insertInto: managedContext)
                
                guard
                    let close = point[ChartKey.close.rawValue] as? Float,
                    let open = point[ChartKey.open.rawValue] as? Float,
                    let low =  point[ChartKey.low.rawValue] as? Float,
                    let high = point[ChartKey.high.rawValue] as? Float,
                    let volume = point[ChartKey.volume.rawValue] as? Float
                else {
                    return
                }
                
                stockPoint.date = date
                stockPoint.close = close
                stockPoint.open = open
                stockPoint.high = high
                stockPoint.low = low
                stockPoint.volume = volume
                stockPoint.owner = stock
                
                do {
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                    completion(false, StockDataError.SaveError)
                }
            }
        
            completion(true, nil)
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
                                  completion: @escaping (Bool, StockDataError?) -> Void) {

        guard let symbol = stock.symbol else {
            completion(false, StockDataError.SaveError); return
        }
        
        self.fetchStockChartFor(symbol: symbol, timeRange: .OneMonth) { (success, data, error) in
            if success {
                
                guard let data = data else {
                    completion(false, StockDataError.SaveError); return
                }
                
                self.saveStockChartTo(stock: stock, data: data, completion: { (success, error) in
                    if success { completion(true, nil) }
                    else { completion(false, StockDataError.SaveError) }
                })
                
            } else {
                completion(false, error)
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
