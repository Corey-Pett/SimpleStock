//
//  NotificationManager.swift
//  SimpleStock
//
//  Created by Corey Pett on 4/18/17.
//  Copyright © 2017 Corey Pett. All rights reserved.
//

import Foundation
import UIKit

final class NotificationManager {
    
    /// Everything should work. None of these alerts should ever show.
    ///
    /// - Parameters:
    ///   - view: the displayed view
    ///   - title: title of the alert
    ///   - message: message of the alert
    final public func presentSimpleAlertOn(vc: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Terminate", style: .destructive, handler: { (_) in
            fatalError() // Should not be in app release
        })
        alert.addAction(action)
        vc.present(alert, animated: true, completion: nil)
    }
}
