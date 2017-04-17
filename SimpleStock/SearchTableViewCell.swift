//
//  SearchTableViewCell.swift
//  SimpleStock
//
//  Created by Corey Pett on 4/17/17.
//  Copyright © 2017 Corey Pett. All rights reserved.
//

import UIKit

final class SearchTableViewCell: UITableViewCell {

    static var reuseIdentifier = "\(SearchTableViewCell.self)"
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    
    final public func configure(stock: Stock) {
        companyNameLabel.text = stock.name
        symbolLabel.text = stock.symbol
    }

}
