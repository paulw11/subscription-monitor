//
//  SubscriptionMonitorProduct.swift
//  SubscriptionMonitor
//
//  Created by Paul Wilkinson on 3/11/16.
//  Copyright © 2016 Paul Wilkinson. All rights reserved.
//

import Foundation
import StoreKit

/** Products are used to encapsulate data associated with the in-app-purchases defined in iTunesConnect.
 - Authors: Paul Wilkinson
 */


public class Product {
    
    /**
    Subscription durations
    */
    public enum SubscriptionDuration: Int {
        /// 7 day subscription duration
        case week = 7
        /// One month subscription duration; this is a calendar month, not 30 days
        case month = 30
        /// Two month subscription duration; this is two calendar months, not 60 days
        case twoMonths = 60
        /// Thee month subscription duration; this is three calendar months, not 90 days
        case threeMonths = 90
        /// Six month subscription duration; this is six calendar months, not 180 days
        case sixMonths = 180
        /// Annual subscription
        case year = 365
        /// Perpetual subscription (only for `FreeProduct`s)
        case perpetual = 9999
    }
    
    /// The product id - must match iTunesConnect
    public let productID: String
    
    /// The product level within its `ProductGroup`
    public let productLevel: Int
    
    /// The duration of this product's subscription
    public let duration: SubscriptionDuration
    
    /// A reference to the associated `SKProduct`
    public let skProduct: SKProduct?
    
    /// Indicates if this is free product (read only)
    public var isFree: Bool {
        get {
            return false
        }
    }
    
    
    /// Create a new `Product`
    /// - Parameter productID: The iTunesConnect product ID
    /// - Parameter productLevel: The product level within its `ProductGroup`
    /// - Parameter duration: The duration of this product's subscription
    /// - Parameter skProduct: A reference to the associated `SKProduct`
    public init(productID: String, productLevel: Int, duration: SubscriptionDuration, skProduct: SKProduct? = nil) {
        self.productID = productID
        self.productLevel = productLevel
        self.duration = duration
        self.skProduct = skProduct
    }
}

extension Product: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.productID)
        hasher.combine(self.productLevel)
        hasher.combine(self.duration)
    }
    
    public static func == (lhs: Product, rhs: Product) -> Bool {
        return (lhs.productID == rhs.productID && lhs.productLevel == rhs.productLevel && lhs.duration == rhs.duration)
    }
    
}
