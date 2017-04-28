//
//  Stock+CoreDataClass.swift
//  SimpleStock
//
//  Created by Corey Pett on 4/18/17.
//  Copyright © 2017 Corey Pett. All rights reserved.
//

import Foundation
import CoreData
import CSV


public class Stock: NSManagedObject {

    private enum Header: String {
        case symbol = "Symbol"
        case name = "Name"
        case lastSale = "LastSale"
        case marketCap = "MarketCap"
        case ipoYear = "IPOyear"
        case sector = "Sector"
        case industry = "industry"
        case summaryQuote = "Summary Quote"
    }
    
    convenience init?(data: Any,
                      managedContext: NSManagedObjectContext) {
        
        let newEntity = NSEntityDescription.entity(forEntityName: "Stock", in: managedContext)
        
        guard let entity = newEntity else {
            return nil
        }
        
        self.init(entity: entity, insertInto: managedContext)
        
        if let csv = data as? CSV {
            self.symbol = csv[Header.symbol.rawValue]
            self.name = csv[Header.name.rawValue]
            self.lastSale = csv[Header.lastSale.rawValue]
            self.marketCap = csv[Header.marketCap.rawValue]
            self.ipoYear = csv[Header.ipoYear.rawValue]
            self.sector = csv[Header.sector.rawValue]
            self.industry = csv[Header.industry.rawValue]
            self.summaryQuote = csv[Header.summaryQuote.rawValue]
        }
    }
    
    
}
