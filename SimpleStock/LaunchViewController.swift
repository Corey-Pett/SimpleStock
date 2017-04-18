//
//  LaunchViewController.swift
//  SimpleStock
//
//  Created by Corey Pett on 4/17/17.
//  Copyright © 2017 Corey Pett. All rights reserved.
//

import UIKit

final class LaunchViewController: UIViewController {

    // MARK: - IBOutlet
    
    @IBOutlet weak var introLabel: UILabel!
    
    // MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Display loading screen
        let progressView = ProgressView(view: self.view, message: "Migrating CSV files to CoreData. Please wait...")
        progressView.showView()
        
        // Setup the transition to CoreData
        CSVHandler().setupApplication { (success, error) in
           
            progressView.hideView()
            
            if success {
                self.present(Storyboard.search.viewController, animated: true, completion: nil)
            } else {
                self.present(error!.alert, animated: true, completion: nil)
            }
        }
    }
}
