import UIKit
import XCTest
import SubscriptionMonitor

class Tests: XCTestCase {
    
    var productGroup: ProductGroup!
    var freeProductGroup: ProductGroup!
    
    var subscriptionMonitor: SubscriptionMonitor!
    var notificationExpectation: XCTestExpectation!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        self.productGroup = ProductGroup(name:"TestGroup")
        
        let product1 = Product(productID: "product1", productLevel: 3, duration: .year)
        let product2 = Product(productID: "product2", productLevel: 1, duration: .twoMonths)
        let product3 = Product(productID: "product3", productLevel: 2, duration: .month)
        
        self.productGroup.add(product:product1)
        self.productGroup.add(product:product2)
        self.productGroup.add(product:product3)
        
        let freeProduct = FreeProduct(productID: "freeProduct", productLevel: 1)
        
        self.freeProductGroup = ProductGroup(name: "FreeGroup")
        self.freeProductGroup.add(product: freeProduct)
    
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testProduct() {
        
        var productSet = Set<Product>()
        
        let product1 = Product(productID: "product1", productLevel: 1, duration: .month)
        let product1a = Product(productID: "product1", productLevel: 1, duration: .month)
        let product2 = Product(productID: "product1", productLevel: 1, duration: .week)
        
        productSet.insert(product1)
        productSet.insert(product1a)
        productSet.insert(product2)
        
        XCTAssert(productSet.count == 2)
        XCTAssert(productSet.contains(product1))
        XCTAssert(productSet.contains(product2))
        
    }
    
    func testProductGroup() {
        
        let products = self.productGroup.products
        
        XCTAssert(products.count == 3, "Incorrect number of products in group")
        
        let p1 = products[0]
        let p2 = products[1]
        let p3 = products[2]
        
        XCTAssert(p1.productLevel <= p2.productLevel)
        XCTAssert(p2.productLevel <= p3.productLevel)
        XCTAssert(p1.duration == .twoMonths)
        XCTAssert(p2.duration == .month)
        XCTAssert(p3.duration == .year)
        
        var productGroupSet = Set<ProductGroup>()
        
        productGroupSet.insert(self.productGroup)
        let secondGroup = ProductGroup(name: self.productGroup.name)
        let thirdGroup = ProductGroup(name: "Third group")
        
        productGroupSet.insert(secondGroup)
        productGroupSet.insert(thirdGroup)
        
        XCTAssert(productGroupSet.count == 2)
        XCTAssert(productGroupSet.contains(self.productGroup))
        XCTAssert(productGroupSet.contains(thirdGroup))
        
    }
    
    func testSubscriptionMonitor() {
        
        let receiptProvider = MockReceiptProvider()
        
        
        if let validator = MockValidator("testreceipt",targetBundle:"me.wilko.subscriptionmonitortest") {
            
            var expectation = self.expectation(description: "Receipt validation")
            
            self.subscriptionMonitor = SubscriptionMonitor(validator: validator, refreshInterval: 10, useSandbox: true, receiptProvider: receiptProvider)
            
            XCTAssert( self.subscriptionMonitor.refreshInterval == 10.0, "Refresh interval not set correctly")
            XCTAssert(self.subscriptionMonitor.useSandbox, "Use sandbox not set correctly")
            if let _ = self.subscriptionMonitor.activeSubscriptions  {
                XCTFail("Unexpected active subscriptions")
            }
            
            self.subscriptionMonitor.add(productGroup: self.productGroup)
            self.subscriptionMonitor.add(productGroup: self.freeProductGroup)
            
            self.subscriptionMonitor.setUpdateCallback({ (receipt, activeProducts, error) -> (Void) in
                expectation.fulfill()
                
                XCTAssert(error==nil, "Did not expect error: \(error!.localizedDescription)")
                XCTAssert(receipt != nil, "Expected a non-nil receipt")
                if let activeProducts = activeProducts {
                    XCTAssert(activeProducts.count == 2,"Expected two active products")
                    XCTAssert(activeProducts[self.freeProductGroup]?.product.productID == "freeProduct")
                    XCTAssert(activeProducts[self.productGroup]?.product.productID == "product2")
                } else {
                    XCTFail("Expected active products")
                }
                
            })
            
            let start=Date()
            
            self.subscriptionMonitor.refreshNow()
            
            XCTAssert(start.timeIntervalSince(self.subscriptionMonitor.lastValidationTime!) < 2)
            
            self.waitForExpectations(timeout: 5.0, handler: { (error) in
                if let error = error {
                    XCTFail(error.localizedDescription)
                }
            })
            
            NotificationCenter.default.addObserver(self, selector: #selector(receiptNotification), name: SubscriptionMonitor.SubscriptionMonitorRefreshNotification, object: nil)
            
            self.subscriptionMonitor.clearUpdateCallback()
            
            self.notificationExpectation = self.expectation(description: "Receipt notification")
            
            self.subscriptionMonitor.refreshNow()
            
            self.waitForExpectations(timeout: 5.0, handler: { (error) in
                if let error = error {
                    XCTFail(error.localizedDescription)
                }
                
                NotificationCenter.default.removeObserver(self)
            })
            
            
            if validator.read(receiptFile: "badtestreceipt") {
                expectation = self.expectation(description: "Bad Receipt validation")
                
                self.subscriptionMonitor.setUpdateCallback({ (receipt, activeProducts, error) -> (Void) in
                    expectation.fulfill()
                    
                    XCTAssert(error != nil, "Expected error")
                    XCTAssert(receipt == nil, "Expected a nil receipt")
                    XCTAssert(activeProducts?.count == 1,"Expected a free product")
                
                })
                
                self.subscriptionMonitor.refreshNow()
                
                self.waitForExpectations(timeout: 5.0, handler: { (error) in
                    if let error = error {
                        XCTFail(error.localizedDescription)
                    }
                })
                
            } else {
                XCTFail("Unable to read bad receipt")
            }
            
        } else {
            XCTFail()
        }
        
        
    }
    
    @objc func receiptNotification() {
        self.notificationExpectation.fulfill()
    }
}
