//
//  Receipt.swift
//  SubscriptionMonitor
//
//  Created by Paul Wilkinson on 4/11/16.
//  Copyright © 2016 Paul Wilkinson. All rights reserved.
//

import Foundation

public class Receipt {
    
    /**
     
     A validated receipt.  Fields are described in the [Receipt Validation Programming Guide](https://developer.apple.com/library/content/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html#//apple_ref/doc/uid/TP40010573-CH106-SW1)
     
      - Authors: Paul Wilkinson
     */
    
    /// Receipt type, sandbox or production
    public let receiptType: String
    
    /// The app’s bundle identifier.
    /// This corresponds to the value of CFBundleIdentifier in the Info.plist file.
    public let bundleId: String
    
    ///This corresponds to the value of CFBundleVersion (in iOS) or CFBundleShortVersionString (in OS X) in the Info.plist file when the purchase was made.
    ///In the sandbox environment, the value of this field is always “1.0”.
    public let applicationVersion: String
    
    /// The date when the app receipt was created.
    public let receiptCreationDate: Date
    
    /// The date when the request was made to validate the receipt
    public let requestDate: Date
    
    /// For a transaction that restores a previous transaction, the date of the original transaction.
    public let originalPurchaseDate: Date
    
    /// The version of the app that was originally purchased.
    public let originalApplicationVersion: String
    
    /// An array of in-app purchase receipts in this receipt
    public var inApp: [InAppReceipt]?
    
    /// The most recent renewal receipt
    public var latestInApp: [InAppReceipt]?
    
    fileprivate let dateFormatter:DateFormatter = {
        let df = DateFormatter()
        let enUSPOSIXLocale = Locale(identifier: "en_US_POSIX")
        df.locale = enUSPOSIXLocale
        df.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
        df.timeZone = TimeZone(secondsFromGMT: 0)
        return df
    }()
    
/**
 Initialise receipt with a JSON representation
 - parameter json: A dictionary that represents the receipt
 */
    public init?(json receiptJson:[String:Any]) {
        
        guard let receiptDictionary = receiptJson["receipt"] as? [String:Any] else {
            return nil
        }
        
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
        
        
        
        if let latestReceiptArray = receiptJson["latest_receipt_info"] as? [[String:Any]] {
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
