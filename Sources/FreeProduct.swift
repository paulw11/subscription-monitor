//
//  FreeProduct.swift
//  Pods
//
//  Created by Paul Wilkinson on 8/11/16.
//
//

import Foundation
import StoreKit

/**
 
 Represents a "free" product.  Free products have a perpetual duration.  They must have a `productID`
 but unlike a `Product` this does not have to exist in iTunesConnect.
 
 - Authors: Paul Wilkinson
 */

public class FreeProduct: Product {
    
    /// Indicates that this is a free product
    
    public override var isFree: Bool {
        get {
            return true
        }
    }
    
    ///
    /// Initialise a new `FreeProduct`.
    ///
    /// - Parameters:
    ///     - productID: The productID associated with this product
    ///     - productLevel: The level associated with this product.  Typically lower that paid products in the same group
    
    public init(productID: String, productLevel: Int) {
        
        super.init(productID: productID, productLevel: productLevel, duration: .perpetual, skProduct: nil)
        
    }
}
