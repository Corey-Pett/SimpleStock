//
//  ProgressView.swift
//  SimpleStock
//
//  Created by Corey Pett on 4/15/17.
//  Copyright © 2017 Corey Pett. All rights reserved.
//

import Foundation
import UIKit

final class ProgressView {
    
    fileprivate var containerView = UIView()
    fileprivate var progressView = UIView()
    fileprivate var activityIndicator = UIActivityIndicatorView()
    fileprivate var view: UIView
    
    init(view: UIView) {
        self.view = view
    }
    
    /// Displays a view that includes an activityIndicator on current view
    ///
    /// - Parameter view: current displayed view
    public func showView() {
        
        containerView.frame = view.frame
        containerView.center = view.center
        
        progressView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        progressView.center = view.center
        progressView.alpha = 0.8
        progressView.backgroundColor = UIColor.gray
        progressView.clipsToBounds = true
        progressView.layer.cornerRadius = 15
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = CGPoint(x: progressView.bounds.width / 2, y: progressView.bounds.height / 2)
        
        progressView.addSubview(activityIndicator)
        containerView.addSubview(progressView)
        view.addSubview(containerView)
        
        activityIndicator.startAnimating()
        
    }
    
    /// Removes ProgressView from view
    public func hideView() {
        activityIndicator.stopAnimating()
        containerView.removeFromSuperview()
    }
}
