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
        
        do {

            let CSVFile = "AMEX"
            
            let handler = CSVHandler()
            
            var csv = try handler.getCSVFor(fileName: CSVFile)
            
            // Parse and save AMEX CSV document
            try handler.saveStockCSV(fileName: CSVFile)
        
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                XCTAssert(false); return
            }
            
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
            
            XCTAssert(true)
            
            
        } catch let error as NSError {
            XCTAssert(false)
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
}
