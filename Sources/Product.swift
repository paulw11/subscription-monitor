//
//  SubscriptionMonitorProduct.swift
//  SubscriptionMonitor
//
//  Created by Paul Wilkinson on 3/11/16.
//  Copyright © 2016 Paul Wilkinson. All rights reserved.
//

import Foundation
import StoreKit

public class Product {
    
    /// Products are used to encapsulate data associated with the in-app-purchases defined in iTunesConnect.
    
    
    public enum SubscriptionDuration: Int {
        case week = 7
        case month = 30
        case twoMonths = 60
        case threeMonths = 90
        case sixMonths = 180
        case year = 365
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
    public var hashValue: Int {
        return self.productID.hashValue ^ self.productLevel ^ self.duration.rawValue
    }
    
    public static func == (lhs: Product, rhs: Product) -> Bool {
        return (lhs.productID == rhs.productID && lhs.productLevel == rhs.productLevel && lhs.duration == rhs.duration)
    }
    
}
