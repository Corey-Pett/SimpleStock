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
        let progressView = ProgressView(view: self.view)
        progressView.message = "Migrating .csv files to CoreData. Please wait..."
        progressView.showView()
        
        // Setup the transition to CoreData
        CSVHandler().setupApplication { (result) in
           
            progressView.hideView()
            
            
            switch result {
                
            case .Success(_):
                self.present(Storyboard.search.viewController, animated: true, completion: nil)
                
            case .Failure(let error):
                self.present(error.alert, animated: true, completion: nil)
                
            }
        }
    }
}
