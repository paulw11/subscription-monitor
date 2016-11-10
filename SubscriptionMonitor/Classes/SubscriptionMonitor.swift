//
//  SubscriptionMonitor.swift
//  SubscriptionMonitor
//
//  Created by Paul Wilkinson on 3/11/16.
//  Copyright © 2016 Paul Wilkinson. All rights reserved.
//

import Foundation
import StoreKit

/// SubscriptionMonitor provides details of valid subscriptions

public class SubscriptionMonitor: NSObject {
    
    public typealias Subscriptions = [ProductGroup:Subscription]
    
    public typealias SubscriptionMonitorCallback = (Receipt?, Subscriptions?, Error?) -> (Void)
    
    /// Subscription refresh interval (seconds)
    public var refreshInterval: Double {
        didSet {
            self.restartTimer()
        }
    }
    
    /// Validate receipts against production or sandbox
    public let useSandbox: Bool
    
    ///
    public let validator: ReceiptValidator
    
    public var lastValidationTime: Date?
    
    static let SubscriptionMonitorRefreshNotification = Notification.Name("SubscriptionMonitorRefreshNotification")
    static let SubscriptionMonitorReceiptValidationFailed = Notification.Name("SubscriptionMonitorReceiptValidationFailed")
    
    public var activeSubscriptions: Subscriptions? {
        get {
            return self.activeSubs
        }
    }
    
    public var latestReceipt: Receipt? {
        get {
            return self.receipt
        }
    }
    
    public var isRefreshEnabled: Bool {
        get {
            return self.isRefreshing
        }
    }
    
    /// Mark:- Private properties
    
    fileprivate var refreshTimer: Timer?
    fileprivate var productGroups = Set<ProductGroup>()
    fileprivate var products = [String:Product]()
    
    fileprivate var receiptProvider: ReceiptProvider
    fileprivate var receipt: Receipt?
    fileprivate var isRefreshing = false {
        didSet {
            if oldValue != isRefreshing {
                self.restartTimer()
            }
        }
    }
    
    fileprivate var activeSubs:Subscriptions?
    
    fileprivate var receiptCallback: SubscriptionMonitorCallback?
    
    /**
     initialise
     
     - Parameter validationEndpoint: The server URL that is called to validate the receipts
     - Parameter refreshInterval: The receipt refresh refreshInterval
     - Parameter useSandbox: `true` if the receipt should be validated against the Apple useSandbox
     - Returns a new SubscriptionMonitor
     */
    
    
    public init(validator: ReceiptValidator, refreshInterval: Double = 3600, useSandbox: Bool = false, receiptProvider: ReceiptProvider = LocalReceiptProvider()) {
        self.validator = validator
        self.useSandbox = useSandbox
        self.refreshInterval = refreshInterval
        self.receiptProvider = receiptProvider
        super.init()
    }
    
    public func add(productGroup: ProductGroup) {
        self.productGroups.insert(productGroup)
        for product in productGroup.products {
            self.products[product.productID] = product
        }
    }
    
    public func remove(productGroup: ProductGroup) {
        for product in productGroup.products {
            self.products[product.productID] = nil
        }
        self.productGroups.remove(productGroup)
    }
    
    public func startRefreshing() {
        self.isRefreshing = true
    }
    
    public func stopRefreshing() {
        self.isRefreshing = false
    }
    
    public func refreshNow() {
        self.restartTimer()
        self.refreshSubscriptions()
    }
    
    public func setUpdateCallback(_ callback:@escaping SubscriptionMonitorCallback) {
        self.receiptCallback = callback
    }
    
    /**
     Restart the refresh Timer
     */
    
    fileprivate func restartTimer() {
        
        self.refreshTimer?.invalidate()
        self.refreshTimer = nil
        
        if (self.isRefreshing) {
            
            self.refreshTimer = Timer.scheduledTimer(timeInterval: self.refreshInterval, target: self, selector: #selector(refreshSubscriptions), userInfo: nil, repeats: true)
        }
    }
    
    @objc fileprivate func refreshSubscriptions() {
        
        self.receiptProvider.getReceipt { (data, error) -> (Void) in
            guard error == nil, let receiptData = data else {
                let validatorError = SubscriptionMonitorError.noReceiptAvailable(rootError: error)
                NotificationCenter.default.post(name: SubscriptionMonitor.SubscriptionMonitorReceiptValidationFailed, object: self, userInfo: ["Error":validatorError])
                self.receiptCallback?(nil,nil,validatorError)
                return
            }
            
            self.validator.validate(receipt: receiptData, forSubscriptionMonitor:self, completion: { (receipt, error) -> (Void) in
                
                guard error == nil, let validatedReceipt = receipt else {
                    let validatorError = SubscriptionMonitorError.validatorError(rootError: error)
                    NotificationCenter.default.post(name: SubscriptionMonitor.SubscriptionMonitorReceiptValidationFailed, object: self, userInfo: ["Error":validatorError])
                    self.receiptCallback?(nil,nil,validatorError)
                    return
                }
                
                self.receipt = nil
                self.activeSubs = nil
                
                do {
                    try self.process(validatedReceipt)
                    self.receiptCallback?(self.receipt,self.activeSubs,nil)
                    NotificationCenter.default.post(name: SubscriptionMonitor.SubscriptionMonitorRefreshNotification, object: self, userInfo:nil)
                } catch {
                    self.receiptCallback?(nil,nil,error)
                    let validatorError = SubscriptionMonitorError.validatorError(rootError: error)
                    NotificationCenter.default.post(name: SubscriptionMonitor.SubscriptionMonitorReceiptValidationFailed, object: self, userInfo: ["Error":validatorError])
                }
                
            })
        }
    }
    
    func process(_ validateReceipt:Receipt) throws {
        
        var productsDict = [String:ProductGroup]()
        
        var activeProducts = Subscriptions()
        
        for productGroup in self.productGroups {
            for product in productGroup.products {
                productsDict[product.productID] = productGroup
                if product.isFree {
                    activeProducts[productGroup] = Subscription(inAppReceipt:nil, product:product)
                }
            }
        }
        
        if let latestInApp = validateReceipt.latestInApp {
            for inapp in latestInApp {
                if self.isActive(inApp: inapp) {
                    guard let potentialProduct = self.products[inapp.productId] else {
                        throw SubscriptionMonitorError.invalidProduct
                    }
                    if let group = productsDict[inapp.productId] {
                        if let currentProduct = activeProducts[group] {
                            if potentialProduct.productLevel < currentProduct.product.productLevel {
                                activeProducts[group] = Subscription(inAppReceipt:inapp, product: potentialProduct)
                            }
                        } else {
                            activeProducts[group] = Subscription(inAppReceipt:inapp, product: potentialProduct)
                        }
                    } else {
                        throw SubscriptionMonitorError.invalidProduct
                    }
                }
            }
        }
        self.activeSubs = activeProducts
        self.receipt = validateReceipt

        
    }
    
    func isActive(inApp: InAppReceipt) -> Bool {
        return inApp.expiresDate > Date()
    }
}

