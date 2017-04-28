//
//  StockPoint+CoreDataClass.swift
//  SimpleStock
//
//  Created by Corey Pett on 4/18/17.
//  Copyright © 2017 Corey Pett. All rights reserved.
//

import Foundation
import CoreData

public class StockPoint: NSManagedObject {
    
    private enum ChartKey: String {
        case volume, open, close, low, high
    }

    convenience init?(data: [String : AnyObject],
          owner: Stock,
          managedContext: NSManagedObjectContext) {
        
        let newEntity = NSEntityDescription.entity(forEntityName: "StockPoint", in: managedContext)
        
        guard let entity = newEntity else {
            return nil
        }
        
        self.init(entity: entity, insertInto: managedContext)
    
        guard
            let close = data[ChartKey.close.rawValue] as? Float,
            let open = data[ChartKey.open.rawValue] as? Float,
            let low =  data[ChartKey.low.rawValue] as? Float,
            let high = data[ChartKey.high.rawValue] as? Float,
            let volume = data[ChartKey.volume.rawValue] as? Float
        else {
            return nil
        }
        
        self.date = NSDate(timeIntervalSince1970: (data["Timestamp"] as? Double ?? data["Date"] as! Double))
        
        self.close = close
        self.open = open
        self.high = high
        self.low = low
        self.volume = volume
        self.owner = owner
        
    }
}
