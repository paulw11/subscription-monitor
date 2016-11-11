//
//  ReceiptValidator.swift
//  SubscriptionMonitor
//
//  Created by Paul Wilkinson on 3/11/16.
//  Copyright © 2016 Paul Wilkinson. All rights reserved.
//

import Foundation

public protocol ReceiptValidator {
    
    typealias ValidationHandler = (Receipt?, Error?) -> (Void)
    
    func validate(receipt: Data, forSubscriptionMonitor: SubscriptionMonitor, completion: @escaping ValidationHandler) -> Void
    
}
