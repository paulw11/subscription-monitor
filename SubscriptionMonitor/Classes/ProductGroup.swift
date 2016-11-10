//
//  SubscriptionMonitorGroup.swift
//  SubscriptionMonitor
//
//  Created by Paul Wilkinson on 3/11/16.
//  Copyright © 2016 Paul Wilkinson. All rights reserved.
//

import Foundation

public class ProductGroup {
    
    
    let name: String
    var products: [Product] {
        get {
            return privateProducts
        }
    }
    
    fileprivate var privateProducts = [Product]()
    
    init(name: String) {
        self.name = name
    }
    
    func add(product: Product) {
        self.privateProducts.append(product)
        self.privateProducts.sort { (product1, product2) -> Bool in
            return (product1.productLevel < product2.productLevel)
        }
    }
    
}

extension ProductGroup: Hashable {
    public var hashValue: Int {
        return self.name.hashValue
    }
    
    public static func == (lhs: ProductGroup, rhs: ProductGroup) -> Bool {
        return lhs.name == rhs.name
    }
    
}
