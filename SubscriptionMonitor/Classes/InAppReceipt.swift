//
//  InAppReceipt.swift
//  SubscriptionManager
//
//  Created by Paul Wilkinson on 4/11/16.
//  Copyright © 2016 Paul Wilkinson. All rights reserved.
//

import Foundation

public class InAppReceipt {
    
    public let quantity: Int
    public let productId: String
    public let transactionId: String
    public let originalTransactionId: String
    public let purchaseDate: Date
    public let originalPurchaseDate: Date
    public let expiresDate: Date
    public let webOrderLine: String
    public let isTrialPeriod: Bool
    public let cancellationDate: Date?
    
    fileprivate let expirationDateFormatter:DateFormatter = {
        let df = DateFormatter()
        let enUSPOSIXLocale = Locale(identifier: "en_US_POSIX")
        df.locale = enUSPOSIXLocale
        df.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
        df.timeZone = TimeZone(secondsFromGMT: 0)
        return df
    }()
    
    
    init?(_ inAppDictionary:[String:Any]) {
        
        guard let quantityStr = inAppDictionary["quantity"] as? String,
            let productId = inAppDictionary["product_id"] as? String,
            let transactionId = inAppDictionary["transaction_id"] as? String,
            let originalTransactionId = inAppDictionary["original_transaction_id"] as? String,
            let webOrderLine = inAppDictionary["web_order_line_item_id"] as? String,
            let purchaseDateStr = inAppDictionary["purchase_date"] as? String,
            let originalPurchaseDateStr = inAppDictionary["original_purchase_date"] as? String,
            let expiresDateStr = inAppDictionary["expires_date"] as? String,
            let trialPeriodStr = inAppDictionary["is_trial_period"] as? String else {
                return nil
        }
        
        guard let purchaseDate = self.expirationDateFormatter.date(from: purchaseDateStr),
            let originalPurchaseDate = self.expirationDateFormatter.date(from: originalPurchaseDateStr),
            let expiresDate = self.expirationDateFormatter.date(from: expiresDateStr),
            let trialPeriod = Bool(trialPeriodStr),
            let quantity = Int(quantityStr)
        else {
                return nil
        }
        
        if let cancellationDateStr = inAppDictionary["cancellation_date"] as? String {
            if let cancellationDate = self.expirationDateFormatter.date(from: cancellationDateStr) {
                self.cancellationDate = cancellationDate
            } else {
                return nil
            }
        } else {
            self.cancellationDate = nil
        }
        
        self.quantity = quantity
        self.productId = productId
        self.transactionId = transactionId
        self.originalTransactionId = originalTransactionId
        self.webOrderLine = webOrderLine
        self.purchaseDate = purchaseDate
        self.originalPurchaseDate = originalPurchaseDate
        self.expiresDate = expiresDate
        self.isTrialPeriod = trialPeriod
        
    }
}
