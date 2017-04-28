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
    
    typealias completion = (CVSResult) -> Void
    
    /// Parses a CSV file and saves each entry as a Stock entity into CoreData on a background thread
    ///
    /// - Parameters:
    ///   - fileName: String name of file inside Bundle.main.path
    ///   - completion: success = true if CSV info is saved correclty, else return CSVHandlerError
    public func saveStockCSV(fileName: String,
                             completion: @escaping (completion)) {
        
        do {
            
            // Get parsed document
            var csv = try self.getCSVFor(fileName: fileName)
            
            // Save to CoreData
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                completion(.Failure(.ErrorParsing)); return
            }
            
            appDelegate.persistentContainer.performBackgroundTask({ (managedContext) in
                while let _ = csv.next() {
                    
                    let _ = Stock(data: csv, managedContext: managedContext)
                    
                    do {
                        try managedContext.save()
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                        completion(.Failure(.ErrorSaving)); return
                    }
                }
                
                completion(.Success(nil))
            })
            
        } catch CSVHandlerError.PathNotFound {
            print("Path not found"); completion(.Failure(.PathNotFound))
        } catch {
            print("Error Parsing CSV"); completion(.Failure(.ErrorParsing))
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
    
    /// Transitions the CSV data into coreData. 
    /// If user exits while this is saving, multiple entries will show.
    /// Could make this atomic, but I am too lazy
    ///
    /// - Parameter completion: success = true if all CSV info is saved correctly, else pass the error back
    public func setupApplication(completion: @escaping (completion)) {
        
        let dataKey = "isDataSaved"
        
        if UserDefaults.standard.bool(forKey: dataKey) {
            completion(.Success(nil)); return
        }
        
        let files = ["AMEX", "NASDAQ", "NYSE"]
        
        let dispatchGroup = DispatchGroup()
        
        for file in files {
            
            dispatchGroup.enter()
            
            self.saveStockCSV(fileName: file, completion: { (result) in
                
                switch result {
                    
                case .Success(_): break;
                case .Failure(let error):
                    completion(.Failure(error)); break
                }
                
                dispatchGroup.leave()
            })
        }
        
        dispatchGroup.notify(queue: .main) {
            UserDefaults.standard.set(true, forKey: dataKey)
            completion(.Success(nil))
        }
    }
}

// MARK: - Public enums

public enum CVSResult {
    case Success(AnyObject?)
    case Failure(CSVHandlerError)
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


