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
final class CSVHandler {
    
    /// Parses a CSV file and saves each entry as a Stock entity into CoreData on a background thread
    ///
    /// - Parameters:
    ///   - fileName: String name of file inside Bundle.main.path
    ///   - completion: success = true if CSV info is saved correclty, else return CSVHandlerError
    final public func saveStockCSV(fileName: String,
                                   completion: @escaping (_ success: Bool, _ error: CSVHandlerError?) -> Void) {
        
        do {
            
            // Get parsed document
            var csv = try self.getCSVFor(fileName: fileName)
            
            // Save to CoreData
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                throw CSVHandlerError.ErrorParsing
            }
            
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
                        completion(false, CSVHandlerError.ErrorSaving)
                    }
                }
                
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            })
            
        } catch CSVHandlerError.PathNotFound {
            print("File not found")
            completion(false, CSVHandlerError.PathNotFound)
        } catch {
            print("Error Parsing CSV")
            completion(false, CSVHandlerError.ErrorParsing)
        }
    }
    
    /// Parses a CSV file
    ///
    /// - Parameter fileName: String name of a file inside Bundle.main.path
    /// - Returns: a CSV object - must import CSV to use
    /// - Throws: throws a CSVHandlerError
    final public func getCSVFor(fileName: String) throws -> CSV {
        
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
    
    /// Transitions the CSV data into coreData. 
    /// If user exits while this is saving, multiple entries will show.
    /// Could make this atomic, but I am too lazy
    ///
    /// - Parameter completion: success = true if all CSV info is saved correctly, else pass the error back
    final public func setupApplication(completion: @escaping (_ success: Bool, _ error: CSVHandlerError?) -> Void) {
        
        let dataKey = "isDataSaved"
        
        if UserDefaults.standard.bool(forKey: dataKey) {
            completion(true, nil); return
        }
        
        let files = ["AMEX", "NASDAQ", "NYSE"]
        
        let dispatchGroup = DispatchGroup()
        
        for file in files {
            
            dispatchGroup.enter()
            
            self.saveStockCSV(fileName: file, completion: { (success, error) in
                if error != nil {
                    completion(false, error); return
                }
                
                dispatchGroup.leave()
            })
        }
        
        dispatchGroup.notify(queue: .main) {
            UserDefaults.standard.set(true, forKey: dataKey)
            completion(true, nil)
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
    case PathNotFound, ErrorSaving, ErrorParsing
    
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
            fatalError() // I know these should not be here in release.
        }
        
        alert.addAction(alertAction)
        return alert
    }
    
}


