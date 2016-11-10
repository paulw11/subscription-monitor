//
//  SubscriptionManagerProduct.swift
//  SubscriptionManager
//
//  Created by Paul Wilkinson on 3/11/16.
//  Copyright © 2016 Paul Wilkinson. All rights reserved.
//

import Foundation
import StoreKit

public class Product {
    
    public enum SubscriptionDuration: Int {
        case week = 7
        case month = 30
        case twoMonths = 60
        case threeMonths = 90
        case sixMonths = 180
        case year = 365
        case perpetual = 9999
    }
    
    public let productID: String
    public let productLevel: Int
    public let duration: SubscriptionDuration
    public let skProduct: SKProduct?
    
    public var isFree: Bool {
        get {
            return false
        }
    }
    
    init(productID: String, productLevel: Int, duration: SubscriptionDuration, skProduct: SKProduct? = nil) {
        self.productID = productID
        self.productLevel = productLevel
        self.duration = duration
        self.skProduct = skProduct
    }
}

extension Product: Hashable {
    public var hashValue: Int {
        return self.productID.hashValue
    }
    
    public static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.productID == rhs.productID
    }
    
}
