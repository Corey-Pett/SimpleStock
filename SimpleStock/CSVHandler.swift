//
//  CSVHandler.swift
//  SimpleStock
//
//  Created by Corey Pett on 4/14/17.
//  Copyright © 2017 Corey Pett. All rights reserved.
//

import Foundation
import CSV
import CoreData

/// A handler to manage CSV files transition to CoreData
struct CSVHandler {
    
    /// Parses a CSV file
    /// and saves each entry as a Stock entity into CoreData on a background thread
    ///
    /// - Parameter fileName: String name of file inside Bundle.main.path
    /// - Throws: throws a CSVHandlerError
    public func saveStockCSV(fileName: String) throws {
        
        do {
            
            // Get parsed document
            var csv = try self.getCSVFor(fileName: fileName)
            
            // Save to CoreData
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                throw CSVHandlerError.ErrorParsing
            }
            
            var coreDataError: Error?
            appDelegate.persistentContainer.performBackgroundTask({ (managedContext) in
                while let _ = csv.next() {
                    
                    let stock = Stock(entity: Stock.entity(), insertInto: managedContext)
                    
                    stock.symbol = csv[Header.symbol.rawValue]
                    stock.name = csv[Header.name.rawValue]
                    stock.lastSale = csv[Header.lastSale.rawValue]
                    stock.marketCap = csv[Header.marketCap.rawValue]
                    stock.ipoYear = csv[Header.ipoYear.rawValue]
                    stock.sector = csv[Header.sector.rawValue]
                    stock.industry = csv[Header.industry.rawValue]
                    stock.summaryQuote = csv[Header.summaryQuote.rawValue]
                    
                    do {
                        try managedContext.save()
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                        coreDataError = error
                    }
                }
            })
            
        if coreDataError != nil { throw CSVHandlerError.ErrorSaving }
            
        } catch CSVHandlerError.PathNotFound {
            print("File not found")
            throw CSVHandlerError.PathNotFound
        } catch {
            print("Error Parsing CSV")
            throw CSVHandlerError.ErrorParsing
        }
    }
    
    /// Parses a CSV file
    ///
    /// - Parameter fileName: String name of a file inside Bundle.main.path
    /// - Returns: a CSV object - must import CSV to use
    /// - Throws: throws a CSVHandlerError
    public func getCSVFor(fileName: String) throws -> CSV {
        
        let fileType = ".csv"
        
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: fileType) else {
            throw CSVHandlerError.PathNotFound
        }
        
        do {
            
            let contents = try String(contentsOfFile: filepath, encoding: .utf8)
            
            return try CSV(
                string: contents,
                hasHeaderRow: true)
            
        } catch {
            print("Error Parsing CSV")
            throw CSVHandlerError.ErrorParsing
        }
    }
}

extension CSVHandler {
    
    /// Transitions the CSV data into coreData
    ///
    /// - Parameter completion: success = true if all CSV info is saved correctly, else pass the error back
    public func setupApplication(completion: @escaping (_ success: Bool, _ error: CSVHandlerError?) -> Void) {
        
        let dataKey = "isDataSaved"
        
        if UserDefaults.standard.bool(forKey: dataKey) {
            completion(true, nil); return
        }
        
        do {
            
            let files = ["AMEX", "NASDAQ", "NYSE"]
            
            for file in files {
                try self.saveStockCSV(fileName: file)
            }
            
            UserDefaults.standard.set(true, forKey: dataKey)
            
            completion(true, nil)
            
        } catch CSVHandlerError.ErrorSaving {
            completion(false, CSVHandlerError.ErrorSaving)
        } catch CSVHandlerError.ErrorParsing {
            completion(false, CSVHandlerError.ErrorParsing)
        } catch CSVHandlerError.PathNotFound {
            completion(false, CSVHandlerError.PathNotFound)
        } catch {
            completion(false, CSVHandlerError.ErrorSaving)
        }
    }
}

public enum Header: String {
    case symbol = "Symbol"
    case name = "Name"
    case lastSale = "LastSale"
    case marketCap = "MarketCap"
    case ipoYear = "IPOyear"
    case sector = "Sector"
    case industry = "industry"
    case summaryQuote = "Summary Quote"
}

public enum CSVHandlerError: Error {
    case PathNotFound
    case ErrorSaving
    case ErrorParsing
    
    var alert: UIAlertController! {
        
        let title = "The universe does not want me to get this job."
        var message: String
        
        switch self {
        case .PathNotFound:
            message = "The file path could not be found. In theory - should be impossible"
        case .ErrorSaving:
            message = "CoreData is at blame."
        case .ErrorParsing:
            message = "I coulda shoulda woulda wrote my own CSV parser. This one apparently screwed me."
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Fail me", style: .destructive) { (action) in
            fatalError()
        }
        
        alert.addAction(alertAction)
        return alert
    }
    
}


