# SubscriptionMonitor

[![CI Status](http://img.shields.io/travis/paulw11/subscription-monitor.svg?style=flat)](https://travis-ci.org/paulw/SubscriptionMonitor)
[![Version](https://img.shields.io/cocoapods/v/SubscriptionMonitor.svg?style=flat)](http://cocoapods.org/pods/SubscriptionMonitor)
[![License](https://img.shields.io/cocoapods/l/SubscriptionMonitor.svg?style=flat)](http://cocoapods.org/pods/SubscriptionMonitor)
[![Platform](https://img.shields.io/cocoapods/p/SubscriptionMonitor.svg?style=flat)](http://cocoapods.org/pods/SubscriptionMonitor)
[![GitHub stars](https://img.shields.io/github/stars/badges/shields.svg?style=social&label=Star)](http://github.com/paulw11/subscription-monitor)
[![GitHub watchers](https://img.shields.io/github/watchers/badges/shields.svg?style=social&label=Watch)](https://github.com/paulw11/subscription-monitor)
[![GitHub followers](https://img.shields.io/github/followers/espadrine.svg?style=social&label=Follow)](http://github.com/paulw11/subscription-monitor)

**A framework for monitoring auto renewing subscriptions on iOS**

SubscriptionMonitor automates the tasks required to validate in-app purchase receipts for auto-renewing subscriptions.
It will periodically refresh the application receipt and validate it against your server.  
An NSNotification (and optionally a closure invocation) is used to let your app know that the receipt has been refreshed 
and that it should check for changes in subscriptions.

**Features**

* Pluggable architecture allows you to define your own receipt validation class
* Support for sandbox and production receipt validation
* Support for "free" products; enable base functionality that can be overridden by subscriptions using in a consistent manner

## Requirements
SubscriptionMonitor supports iOS 9 and above. Your project must be written in Swift 3 in order to integrate SubscriptionMonitor.
An external web server is required to communicate with Apple's servers to perform receipt validation.

## Installation

SubscriptionMonitor is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SubscriptionMonitor"
```

## Using SubscriptionMonitor

Using `SubscriptionManager` is straight-forward:

* Create an instance of a `ReceiptValidator` - `SimpleReceiptValidator` works with the sample `php` script (see below)
```swift
let validator = SimpleReceiptValidator(serverBase: "https://yourserver.yourdomain.com/iTunesReceiptValidator.php", 
    targetBundle:"com.yourdomain.yourapp")
```
* Create an instance of `SubscriptionMonitor` that uses the validator - this needs to held where it won't be released,
such as a property of your `UIApplicationDelegate` class
```swift   
self.subscriptionMonitor = SubscriptionMonitor(validator: validator, 
         refreshInterval: 3600, useSandbox: false)
```
* You need to define the product groups and products for your auto-renewing subscriptions and add these to your SubscriptionMonitor. 
It is important that the product ID and product levels match those defined in iTunesConnect.  
You can also add a 'free' product to a product group.  You won't have a matching product in iTunesConnect for this.  If a
`ProductGroup` contains a free product, then the free product will be 'active' when there are no other active subscriptions
in that product group.
```swift 
let productGroup = ProductGroup(name: "First Product Group")
let product1 = Product(productID: "com.mydomain.myProduct1", productLevel: 1, duration: .year)
let product2 = Product(productID: "com.mydomain.myProduct2", productLevel: 1, duration: .month)
let freeProduct = FreeProduct(productID: "com.mydomain.freeproduct", productLevel: 99)
    
productGroup.add(product: product1)
productGroup.add(product: product2)
productGroup.add(product: FreeProduct)

self.subscriptionMonitor.add(productGroup: productGroup)
```

* Add a closure to be executed when then the receipt and subscription data is updated:
```swift 
self.subscriptionMonitor.setUpdateCallback { (receipt, subscriptions, error) -> Void in
    if error != nil {
       print("There was an error: \(error)")
    }
    //  Note that even after an error there may be active `subscriptions` if you have free products defined
    for subscription in subscriptions {
       print("Active product: \(subscription.product.productID)")
    }
}
```

* You can also subscribe to the `SubscriptionMonitorRefreshNotification` `NSNotification`.  The `userInfo` for this
notification may contain keys for "Error", "Active" and "Receipt" depending on the validation result.

* Call `startRefreshing` to start the time-based refreshing of receipt and subscription information:
```swift
self.subscriptionMonitor.startRefreshing()
```

* A manual receipt validation and refresh can be triggered using `refreshNow`
```swift 
self.subscriptionMonitor.refreshNow()
```

## Server side script

Apple advises that you should use a server to provide an interface between your app and their receipt validation server as this 
allows you to build additional levels of security and trust into the process.  The `SimpleReceiptValidator` class that is included
with SubscriptionMonitor is written to work with the `iTunesReceiptValidator.php` script that can be found in the [php](https://github.com/paulw11/subscription-monitor/tree/master/php) directory
in the repo.  This script needs to be modified to contain the shared secret that can be retrieved from iTunesConnect.

## Author

paulw, paulw@wilko.me

## License

SubscriptionMonitor is available under the MIT license. See the LICENSE file for more info.
