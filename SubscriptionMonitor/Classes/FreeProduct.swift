//
//  FreeProduct.swift
//  Pods
//
//  Created by Paul Wilkinson on 8/11/16.
//
//

import Foundation
import StoreKit

public class FreeProduct: Product {
    
    public override var isFree: Bool {
        get {
            return true
        }
    }
    
    init(productID: String, productLevel: Int) {
        
        super.init(productID: productID, productLevel: productLevel, duration: .perpetual, skProduct: nil)
        
    }
}
