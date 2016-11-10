# SubscriptionMonitor

[![CI Status](http://img.shields.io/travis/paulw11/SubscriptionMonitor.svg?style=flat)](https://travis-ci.org/paulw/SubscriptionMonitor)
[![Version](https://img.shields.io/cocoapods/v/SubscriptionMonitor.svg?style=flat)](http://cocoapods.org/pods/SubscriptionMonitor)
[![License](https://img.shields.io/cocoapods/l/SubscriptionMonitor.svg?style=flat)](http://cocoapods.org/pods/SubscriptionMonitor)
[![Platform](https://img.shields.io/cocoapods/p/SubscriptionMonitor.svg?style=flat)](http://cocoapods.org/pods/SubscriptionMonitor)

**A framework for monitoring auto renewing subscriptions on iOS**
SubscriptionMonitor automates the tasks required to validate in-app purchase receipts for auto-renewing subscriptions.
It will periodically refresh the application receipt and validate it against your server.  It will then deliver an NSNotification (and optionally invoke a closure) to let your app know that the receipt has been refreshed and that it should check for changes in subscriptions.

## Requirements
SubscriptionManager supports iOS 9 and above. Your project must be written in Swift 3 in order to integrate SubscriptionManager.
An external web server is required to communicate with Apple's servers to perform receipt validation.

## Installation

SubscriptionMonitor is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SubscriptionMonitor"
```

## Using SubscriptionMonitor

## Author

paulw, paulw@wilko.me

## License

SubscriptionMonitor is available under the MIT license. See the LICENSE file for more info.
