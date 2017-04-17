//
//  Storyboard.swift
//  SimpleStock
//
//  Created by Corey Pett on 4/17/17.
//  Copyright © 2017 Corey Pett. All rights reserved.
//

import Foundation
import UIKit

public enum Storyboard: String {
    case main
    case chart
    case search
    
    var viewController: UIViewController! {
        return storyboard.instantiateViewController(withIdentifier: "root" + "\(self.rawValue.capitalized)")
    }
    
    var storyboard: UIStoryboard! {
        return UIStoryboard(name: self.rawValue.capitalized, bundle: nil)
    }
}
