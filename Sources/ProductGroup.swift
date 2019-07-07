//
//  SubscriptionMonitorGroup.swift
//  SubscriptionMonitor
//
//  Created by Paul Wilkinson on 3/11/16.
//  Copyright © 2016 Paul Wilkinson. All rights reserved.
//

import Foundation

public class ProductGroup {
    
    /// ProductGroups are used to contain related products. User's can upgrade/downgrade/crossgrade based on the product
    /// level within the group.
    /// - Authors: Paul Wilkinson
    
    /// The group name
    public let name: String
    
    /// The `Products` in this group.  Read only
    public var products: [Product] {
        get {
            return privateProducts
        }
    }
    
    fileprivate var privateProducts = [Product]()
    
    /// Create a new `ProductGroup`
    /// - Parameter name: The name of the new group
    public init(name: String) {
        self.name = name
    }
    
    /// Add a `Product` to the group
    /// - Parameter product: The `Product` to add
    
    public func add(product: Product) {
        self.privateProducts.append(product)
        self.privateProducts.sort { (product1, product2) -> Bool in
            return (product1.productLevel < product2.productLevel)
        }
    }
    
}

extension ProductGroup: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    public static func == (lhs: ProductGroup, rhs: ProductGroup) -> Bool {
        return lhs.name == rhs.name
    }
    
}
