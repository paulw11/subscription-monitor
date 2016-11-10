//
//  MockValidator.swift
//  SubscriptionManager
//
//  Created by Paul Wilkinson on 4/11/16.
//  Copyright © 2016 Paul Wilkinson. All rights reserved.
//

import Foundation
import SubscriptionMonitor

class MockValidator: ReceiptValidator {
    
    let receipt: Receipt?
    let targetBundle: String
    
    init?(_ receiptFile: String, targetBundle: String) {
        
        let bundle = Bundle(for: MockReceiptProvider.self)
        self.targetBundle = targetBundle
        
        if let path = bundle.path(forResource: receiptFile, ofType: "json") {
            let fileUrl = URL(fileURLWithPath: path)
            do {
                let jsonData = try Data(contentsOf: fileUrl)
                if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String:Any] {
                    if let receiptDict = jsonObject["receipt"] as? [String: Any] {
                        if let receipt = Receipt(receiptDict) {
                            self.receipt = receipt
                            return
                        }
                    }
                }
            }
            catch {
                return nil
            }
        }
        
        return nil
        
    }
    
    func validate(receipt: Data, forSubscriptionMonitor: SubscriptionMonitor, completion: @escaping ReceiptValidator.ValidationHandler) -> Void {
        
        guard let receipt = self.receipt else {
            completion(nil,SubscriptionMonitorError.noReceiptAvailable(rootError: nil))
            return
        }
        
        if receipt.bundleId == self.targetBundle {
            completion(receipt,nil)
        } else {
            completion(nil,SubscriptionMonitorError.validateFailed(message: "\(receipt.bundleId) does not match required bundle id - \(self.targetBundle)"))
        }
        
    }
    
}
