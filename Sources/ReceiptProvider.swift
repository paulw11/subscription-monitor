//
//  ReceiptProvider.swift
//  SubscriptionMonitor
//
//  Created by Paul Wilkinson on 4/11/16.
//  Copyright © 2016 Paul Wilkinson. All rights reserved.
//

import Foundation


/// Error thrown of `ReceiptProvider`
/// May include root ErrorType

enum ReceiptProviderError: Error {
    case fetchFailed(rootError: Error?)
}

/** 
   Implement this protocol in order to provide receipt data to a `SubscriptionMonitor` instance
 */

public protocol ReceiptProvider: class {
    
    /**
     A closure to be invoked when receipt data is retrieved (or an error occurs retrieving receipt data).
     
     - parameter receipt: The data that was retrieved
     - parameter error: The error, if any, that resulted from attempting to retrieve the receipt data.
     
     */
    
    typealias ReceiptHandler = (_ receipt: Data?, _ error: Error?) -> (Void)
    
    /**
      Retrieve receipt data and return it to the provided handler
      
      - parameter handler: A `ReceiptHandler` to be invoked with the retrieved receipt data or an error
    */
 
    func getReceipt(handler:@escaping ReceiptHandler) -> Void
    
}



