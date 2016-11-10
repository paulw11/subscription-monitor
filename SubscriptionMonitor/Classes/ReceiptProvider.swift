//
//  ReceiptProvider.swift
//  SubscriptionMonitor
//
//  Created by Paul Wilkinson on 4/11/16.
//  Copyright © 2016 Paul Wilkinson. All rights reserved.
//

import Foundation

enum ReceiptProviderError: Error {
    case fetchFailed(rootError: Error?)
}

public protocol ReceiptProvider: class {
    
    typealias ReceiptHandler = (Data?, Error?) -> (Void)
    
    func getReceipt(handler:@escaping ReceiptHandler) -> Void
    
}



