//
//  Reachability.swift
//  SimpleStock
//
//  Created by Corey Pett on 4/19/17.
//  Copyright © 2017 Corey Pett. All rights reserved.
//  
//  COPIED AND PASTED FROM STACKOVERFLOW USER: KK7

import Foundation
import AFNetworking

protocol NetworkReachabilityDelegate {
    var networkReachability: NetworkReachability { get set }
    func reachabilityChanged(status: NetworkReachabilityStatus)
}

enum NetworkReachabilityStatus {
    case unknown
    case notReachable
    case reachable
}

final class NetworkReachability {
    private var previousNetworkReachabilityStatus: NetworkReachabilityStatus = .unknown
    var delegate: NetworkReachabilityDelegate?
    
    func startMonitoring() {
        AFNetworkReachabilityManager.shared().startMonitoring()
        AFNetworkReachabilityManager.shared().setReachabilityStatusChange { status in
            // This var is declared so you don't need to import AFNetworking everytime you conform to NetworkReachabilityDelegate
            var networkStatus: NetworkReachabilityStatus
            
            switch status {
            case .unknown:
                networkStatus = .unknown
            case .notReachable:
                networkStatus = .notReachable
            case .reachableViaWiFi, .reachableViaWWAN:
                networkStatus = .reachable
            }
            
            if (self.previousNetworkReachabilityStatus != .unknown && networkStatus != self.previousNetworkReachabilityStatus) {
                self.delegate?.reachabilityChanged(status: networkStatus)
            }
            self.previousNetworkReachabilityStatus = networkStatus
        }
    }
    
    func stopMonitoring() {
        AFNetworkReachabilityManager.shared().stopMonitoring()
    }
}
