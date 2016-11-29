//
//  ReceiptValidator.swift
//  SubscriptionMonitor
//
//  Created by Paul Wilkinson on 3/11/16.
//  Copyright © 2016 Paul Wilkinson. All rights reserved.
//

import Foundation

/**
 Implement this protocol in order to validate raw receipt data and provide a validated `Receipt` instance
 */

public protocol ReceiptValidator {
    
    /**
     A closure to be invoked when receipt data is retrieved (or an error occurs retrieving receipt data).
     
     - parameter receipt: The `Receipt` that was parsed and validated
     - parameter error: The error, if any, that resulted from attempting to validate the receipt data.
     
     */
    
    typealias ValidationHandler = (_ receipt:Receipt?, _ error: Error?) -> (Void)
    
    /**
     Validate raw receipt data and return a valid `Receipt` or `Error` via the completion handler
 
     - parameter receipt: The raw receipt data that was retrieved from a `ReceiptProvider`
     - parameter forSubscriptionMonitor: The `SubscriptionMonitor` instance that is making this request
     - parameter completion: The `ValidationHandler` closure to be invoked with the validation result
    */
    
    func validate(receipt: Data, forSubscriptionMonitor: SubscriptionMonitor, completion: @escaping ValidationHandler) -> Void
    
}
