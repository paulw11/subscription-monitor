import UIKit
import XCTest
import SubscriptionMonitor

class Tests: XCTestCase {
    
    var productGroup: ProductGroup!
    var freeProductGroup: ProductGroup!
    
    var subscriptionMonitor: SubscriptionMonitor!
    
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
        
    }
    
    func testSubscriptionMonitor() {
        
        let receiptProvider = MockReceiptProvider()
        
        
        if let validator = MockValidator("testreceipt",targetBundle:"me.wilko.subscriptionmonitortest") {
            
            let expectation = self.expectation(description: "Receipt validation")
            
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
            
            self.subscriptionMonitor.refreshNow()
            
            self.waitForExpectations(timeout: 5.0, handler: { (error) in
                if let error = error {
                    XCTFail(error.localizedDescription)
                }
            })
            
            
        } else {
            XCTFail()
        }
    }
    
}
