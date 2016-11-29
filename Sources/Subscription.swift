//
//  Subscription.swift
//  Pods
//
//  Created by Paul Wilkinson on 6/11/16.
//
//

import Foundation

/** Represents an active subscription */
public struct Subscription {
    /// The `InAppReceipt` (if any) associated with this subscription
    public let inAppReceipt: InAppReceipt?
    /// The `Product` for this subscription
    public let product: Product
}
