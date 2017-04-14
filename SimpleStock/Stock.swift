//
//  Stock.swift
//  SimpleStock
//
//  Created by Corey Pett on 4/14/17.
//  Copyright © 2017 Corey Pett. All rights reserved.
//

import Foundation

struct Stock {
    
    var symbol: String
    var name: String
    var lastSale: String
    var marketCap: String
    var ipoYear: String
    var sector: String
    var industry: String
    var summaryQuote: String
    
    init(symbol: String,
         name: String,
         lastSale: String,
         marketCap: String,
         ipoYear: String,
         sector: String,
         industry: String,
         summaryQuote: String)
    {
        self.symbol = symbol
        self.name = name
        self.lastSale = lastSale
        self.marketCap = marketCap
        self.ipoYear = ipoYear
        self.sector = sector
        self.industry = industry
        self.summaryQuote = summaryQuote
        
    }
    
}
