//
//  MockReceiptProvider.swift
//  SubscriptionManager
//
//  Created by Paul Wilkinson on 4/11/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import SubscriptionMonitor

class MockReceiptProvider: ReceiptProvider {
    
    func getReceipt(handler: @escaping ReceiptProvider.ReceiptHandler) {
        handler(Data(),nil)
    }
    
}
