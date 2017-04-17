//
//  StockChart+CoreDataProperties.swift
//  SimpleStock
//
//  Created by Corey Pett on 4/15/17.
//  Copyright © 2017 Corey Pett. All rights reserved.
//

import Foundation
import CoreData


extension StockChart {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StockChart> {
        return NSFetchRequest<StockChart>(entityName: "StockChart")
    }

    @NSManaged public var close: Float
    @NSManaged public var date: NSDate?
    @NSManaged public var high: Float
    @NSManaged public var low: Float
    @NSManaged public var open: Float
    @NSManaged public var volume: Float

}
