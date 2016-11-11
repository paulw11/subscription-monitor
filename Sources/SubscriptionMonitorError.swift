//
//  SubscriptionMonitorError.swift
//  SubscriptionMonitor
//
//  Created by Paul Wilkinson on 4/11/16.
//  Copyright © 2016 Paul Wilkinson. All rights reserved.
//

import Foundation


public enum SubscriptionMonitorError: Error {
    
    case noReceiptAvailable(rootError: Error?)
    case validatorError(rootError: Error?)
    case validateFailed(message: String?)
    case invalidProductDuration
    case invalidProduct
    
    var description: String {
        switch self {
        case .noReceiptAvailable(let rootError):
            if rootError != nil {
                return (rootError?.localizedDescription)!
            }
            else {
                return "Invalid host"
            }
            
        case .validatorError(let rootError):
            if rootError != nil {
                return (rootError?.localizedDescription)!
            }
            else {
                return "Validation failed"
            }
            
        case .validateFailed(let message):
            let msg = message ?? ""
            return "Validation failed \(msg)"
            
        case .invalidProductDuration:
            return "Free product must be perpetual"
            
        case .invalidProduct:
            return "Invalid product"
        }
    }
    
    var localizedDescription: String {
        return self.description
    }
}
