//
//  Stock+CoreDataProperties.swift
//  SimpleStock
//
//  Created by Corey Pett on 4/18/17.
//  Copyright © 2017 Corey Pett. All rights reserved.
//

import Foundation
import CoreData


extension Stock {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Stock> {
        return NSFetchRequest<Stock>(entityName: "Stock")
    }

    @NSManaged public var industry: String?
    @NSManaged public var ipoYear: String?
    @NSManaged public var lastSale: String?
    @NSManaged public var marketCap: String?
    @NSManaged public var name: String?
    @NSManaged public var sector: String?
    @NSManaged public var summaryQuote: String?
    @NSManaged public var symbol: String?
    @NSManaged public var points: NSSet?

}

// MARK: Generated accessors for points
extension Stock {

    @objc(addPointsObject:)
    @NSManaged public func addToPoints(_ value: StockPoint)

    @objc(removePointsObject:)
    @NSManaged public func removeFromPoints(_ value: StockPoint)

    @objc(addPoints:)
    @NSManaged public func addToPoints(_ values: NSSet)

    @objc(removePoints:)
    @NSManaged public func removeFromPoints(_ values: NSSet)

}
