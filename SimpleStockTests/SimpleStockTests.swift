//
//  SimpleStockTests.swift
//  SimpleStockTests
//
//  Created by Corey Pett on 4/15/17.
//  Copyright © 2017 Corey Pett. All rights reserved.
//

import XCTest
import CoreData
import CSV
@testable import SimpleStock

class SimpleStockTests: XCTestCase {
    
    func testCSVSave() {
        
        let CSVFile = "NASDAQ"
        let handler = CSVHandler()
        
        let expect = expectation(description: "Save Stock")
        
        // Parse and save AMEX CSV document
        handler.saveStockCSV(fileName: CSVFile, completion: { (success, error) in
    
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                XCTAssert(false); return
            }
            
            do {
                
                var csv = try handler.getCSVFor(fileName: CSVFile)
                let managedContext = appDelegate.persistentContainer.viewContext
                let stocks = try managedContext.fetch(Stock.fetchRequest())
                
                // Loop through parsed document and saved data
                var index = 0
                while let _ = csv.next() {
        
                    let stock = stocks[index] as! Stock
                                    
                    if stock.symbol != csv[Header.symbol.rawValue]
                    {XCTAssert(false)}

                    if stock.name != csv[Header.name.rawValue]
                    {XCTAssert(false)}

                    if stock.lastSale != csv[Header.lastSale.rawValue]
                    {XCTAssert(false)}

                    if stock.marketCap != csv[Header.marketCap.rawValue]
                    {XCTAssert(false)}

                    if stock.ipoYear != csv[Header.ipoYear.rawValue]
                    {XCTAssert(false)}

                    if stock.sector != csv[Header.sector.rawValue]
                    {XCTAssert(false)}
                    
                    if stock.industry != csv[Header.industry.rawValue]
                    {XCTAssert(false)}

                    if stock.summaryQuote != csv[Header.summaryQuote.rawValue]
                    {XCTAssert(false)}
                    
                    index = 1 + index
                }
                
                // Delete entries after test
                let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Stock")
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
                try managedContext.execute(deleteRequest)
                try managedContext.save()
                
                expect.fulfill()
                
            } catch let error as NSError {
                print("\(error), \(error.userInfo)"); XCTAssert(false)
            }
        })
        
        waitForExpectations(timeout: 60) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                
                XCTAssert(false)
            }
        }
    }
    
    func testStockFetch() {
        
        let symbol = "AMD"
        let timeRange = ChartTimeRange.OneMonth
        
        var dataCount = Int()
        switch (timeRange) {
            
        case .OneDay:
            dataCount = 1
        case .FiveDays:
            dataCount = 5
        case .TenDays:
            dataCount = 10
        case .OneMonth:
            dataCount = 20
        }
        
        let expect = expectation(description: "Fetch Stock Chart")

        StockData().fetchStockChartFor(symbol: symbol, timeRange: timeRange) { (data, error) in
            
            if data?.count == dataCount {
                XCTAssert(true)
            } else {
                XCTAssert(false)
            }
            
            expect.fulfill()

        }
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                XCTAssert(false)
            }
        }
        
    }
    
//    func testCoreDataOwnership() {
//        
//        let symbol = "AMD"
//        let timeRange = ChartTimeRange.OneMonth
//        
//        var dataCount = Int()
//        switch (timeRange) {
//            
//        case .OneDay:
//            dataCount = 1
//        case .FiveDays:
//            dataCount = 5
//        case .TenDays:
//            dataCount = 10
//        case .OneMonth:
//            dataCount = 30
//        }
//        
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            XCTAssert(false); return
//        }
//        
//        let expect = expectation(description: "Core Data Ownership")
//        
//        let fetchRequest: NSFetchRequest<Stock> = Stock.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "symbol == %@", symbol)
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "symbol", ascending: true)]
//        
//        StockData().fetchStockChartFor(symbol: symbol, timeRange: timeRange) { (data, error) in
//            
//            do {
//                let results = try appDelegate.persistentContainer.viewContext.fetch(fetchRequest)
//                let stock = results.first!
//                
//                StockData().saveStockChartTo(stock: stock, data: data!, completion: { (success, error) in
//                    if success {
//                        
//                        print(stock.points)
//                        
//                        if stock.points?.count == dataCount {
//                            XCTAssert(true)
//                        } else {
//                            XCTAssert(false)
//                        }
//                        
//                        expect.fulfill()
//                    }
//                })
//                
//            } catch {
//                XCTAssert(false)
//            }
//            
//        }
//        
//        waitForExpectations(timeout: 60) { (error) in
//            if let error = error {
//                print("Error: \(error.localizedDescription)")
//                XCTAssert(false)
//            }
//        }
//        
//    }
    
}
