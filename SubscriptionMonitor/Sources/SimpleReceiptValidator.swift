//
//  SimpleReceiptValidator.swift
//  Pods
//
//  Created by Paul Wilkinson on 7/11/16.
//
//

import Foundation


public class SimpleReceiptValidator: ReceiptValidator {
    
    let serverBase: String
    let targetBundle: String
    
    
    public init(serverBase: String, targetBundle: String) {
        self.serverBase = serverBase
        self.targetBundle = targetBundle
    }
    
    public func validate(receipt: Data, forSubscriptionMonitor monitor: SubscriptionMonitor, completion: @escaping (Receipt?, Error?) -> (Void)) {
        
        let base64Receipt = receipt.base64EncodedString().replacingOccurrences(of: "+", with: "%2B")
        
        let sandbox = monitor.useSandbox ? "?sandbox=true" : ""
        let urlString = "\(self.serverBase)\(sandbox)"
        
        guard let url = URL(string: urlString) else {
            completion(nil,SubscriptionMonitorError.validateFailed(message: "Invalid URL: \(urlString)"))
            return
        }
        
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        
        let paramString = "receipt=\(base64Receipt)"
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            guard error == nil  else {
                completion(nil,SubscriptionMonitorError.validatorError(rootError: error))
                return
            }
            if let jsonData = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String:AnyObject] {
                        if let status = json["status"] as? Int {
                            if status == 0 {
                                    if let receipt = Receipt(json) {
                                        if receipt.bundleId == self.targetBundle {
                                            completion(receipt,nil)
                                        } else {
                                            completion(receipt,SubscriptionMonitorError.validateFailed(message: "Bundle did not match tareget"))
                                            return
                                        }
                                    }
                            } else {
                                completion(nil,SubscriptionMonitorError.validateFailed(message: "Server returned non-zero status: \(status)"))
                                return
                            }
                        }
                    }
                    
                } catch {
                    completion(nil,SubscriptionMonitorError.validatorError(rootError: error))
                    return
                }
                
            } else {
                completion(nil,SubscriptionMonitorError.validateFailed(message: "Unable to validate receipt"))
            }
        });
        
        task.resume()
    }
}
