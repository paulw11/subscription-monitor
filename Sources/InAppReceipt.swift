//
//  InAppReceipt.swift
//  SubscriptionMonitor
//
//  Created by Paul Wilkinson on 4/11/16.
//  Copyright © 2016 Paul Wilkinson. All rights reserved.
//

import Foundation

/**
 
 An InApp purchase from a validated receipt.  Fields are described in the [Receipt Validation Programming Guide](https://developer.apple.com/library/content/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html#//apple_ref/doc/uid/TP40010573-CH106-SW1)
 
 - Authors: Paul Wilkinson
 */

public class InAppReceipt {
    
    /// This value corresponds to the quantity property of the `SKPayment` object stored in the transaction’s `payment` property.
    public let quantity: Int
    
    /// This value corresponds to the productIdentifier property of the `SKPayment` object stored in the transaction’s `payment` property
    public let productId: String
    
    /// This value corresponds to the transaction’s `transactionIdentifier` property.
    
    public let transactionId: String
    
    /// This value corresponds to the original transaction’s `transactionIdentifier` property.
    /// All receipts in a chain of renewals for an auto-renewable subscription have the same value for this field.
    public let originalTransactionId: String
    
    /// This value corresponds to the original transaction’s `transactionDate` property.
    /// In an auto-renewable subscription receipt, this indicates the beginning of the subscription period, even if the subscription has been renew
    public let originalPurchaseDate: Date
    
    /// This value corresponds to the transaction’s `transactionDate` property.
    /// For a transaction that restores a previous transaction, the purchase date is the same as the original purchase date. Use `originalPurchaseDate` to get the date of the original transaction.
    /// In an auto-renewable subscription receipt, this is always the date when the subscription was purchased or renewed, regardless of whether the transaction has been restored.
    public let purchaseDate: Date
    
    ///T he expiration date for the subscription
    public let expiresDate: Date
    
    /// The primary key for identifying subscription purchases.
    public let webOrderLine: String
    
    /// Indicates whether this subscription is in the trial period
    public let isTrialPeriod: Bool
    
    /// For a transaction that was canceled by Apple customer support, the time and date of the cancellation.
    /// Treat a canceled receipt the same as if no purchase had ever been made.
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
    
    /// Check if this purchase was 'active' on the given date.
    /// It is active if it isn't cancelled, it was purchased before the given date and expires after the given date
    /// - Parameter on: The date on which to check for validity
    /// - Return: `true` if the purchase was active on the given date
    
    public func isActive(on: Date) -> Bool {
        
        guard self.cancellationDate == nil else {
            return false
        }
        
        return self.purchaseDate <= on && self.expiresDate > on
    }
    
}
