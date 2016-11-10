//
//  Receipt.swift
//  SubscriptionMonitor
//
//  Created by Paul Wilkinson on 4/11/16.
//  Copyright © 2016 Paul Wilkinson. All rights reserved.
//

import Foundation

public class Receipt {
    
    public let receiptType: String
    public let bundleId: String
    public let applicationVersion: String
    public let receiptCreationDate: Date
    public let requestDate: Date
    public let originalPurchaseDate: Date
    public let originalApplicationVersion: String
    
    public let inApp: [InAppReceipt]?
    public let latestInApp: [InAppReceipt]?
    
    fileprivate let dateFormatter:DateFormatter = {
        let df = DateFormatter()
        let enUSPOSIXLocale = Locale(identifier: "en_US_POSIX")
        df.locale = enUSPOSIXLocale
        df.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
        df.timeZone = TimeZone(secondsFromGMT: 0)
        return df
    }()
    
    public init?(_ receiptDictionary:[String:Any]) {
        
        guard let receiptType = receiptDictionary["receipt_type"] as? String,
            let bundleId = receiptDictionary["bundle_id"] as? String,
            let applicationVersion = receiptDictionary["application_version"] as? String,
            let receiptCreationDateStr = receiptDictionary["receipt_creation_date"] as? String,
            let requestDateStr = receiptDictionary["request_date"] as? String,
            let originalPurchaseDateStr = receiptDictionary["original_purchase_date"] as? String,
            let originalApplicationVersion = receiptDictionary["original_application_version"] as? String
            else {
                return nil
        }
        
        guard let receiptCreationDate = self.dateFormatter.date(from:receiptCreationDateStr),
            let requestDate = self.dateFormatter.date(from:requestDateStr),
            let originalPurchaseDate = self.dateFormatter.date(from:originalPurchaseDateStr) else {
                return nil
        }
        
        self.receiptType = receiptType
        self.bundleId = bundleId
        self.applicationVersion = applicationVersion
        self.receiptCreationDate = receiptCreationDate
        self.requestDate = requestDate
        self.originalPurchaseDate = originalPurchaseDate
        self.originalApplicationVersion = originalApplicationVersion
        
        if let inAppArray = receiptDictionary["in_app"] as? [[String:Any]] {
            if !inAppArray.isEmpty {
                self.inApp = [InAppReceipt]()
                for inAppDictionary in inAppArray {
                    if let newReceipt = InAppReceipt(inAppDictionary) {
                        self.inApp?.append(newReceipt)
                    }
                }
            } else {
                self.inApp = nil
            }
        } else {
            self.inApp = nil
        }
        
        if let latestReceiptArray = receiptDictionary["latest_receipt_info"] as? [[String:Any]] {
            if (!latestReceiptArray.isEmpty) {
                self.latestInApp = [InAppReceipt]()
                for inAppDictionary in latestReceiptArray {
                    if let newReceipt = InAppReceipt(inAppDictionary) {
                        self.latestInApp?.append(newReceipt)
                    }
                }
            } else {
                self.latestInApp = nil
            }
        } else {
            self.latestInApp = nil
        }
        
    }
    
}
