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
    
    public func validate(receipt: Data, forSubscriptionManager manager: SubscriptionManager, completion: @escaping (Receipt?, Error?) -> (Void)) {
        
        let base64Receipt = receipt.base64EncodedString().replacingOccurrences(of: "+", with: "%2B")
        
        let sandbox = manager.useSandbox ? "?sandbox=true" : ""
        let urlString = "\(self.serverBase)\(sandbox)"
        
        guard let url = URL(string: urlString) else {
            completion(nil,SubscriptionManagerError.validateFailed(message: "Invalid URL: \(urlString)"))
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
                completion(nil,SubscriptionManagerError.validatorError(rootError: error))
                return
            }
            if let jsonData = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String:AnyObject] {
                        if let status = json["status"] as? Int {
                            if status == 0 {
                                if let receiptDict = json["receipt"] as? [String:AnyObject] {
                                    if let receipt = Receipt(receiptDict) {
                                        if receipt.bundleId == self.targetBundle {
                                            completion(receipt,nil)
                                        } else {
                                            completion(receipt,SubscriptionManagerError.validateFailed(message: "Bundle did not match tareget"))
                                            return
                                        }
                                    }
                                } else {
                                    completion(nil,SubscriptionManagerError.validateFailed(message: "Could not parse receipt"))
                                    return
                                }
                            } else {
                                completion(nil,SubscriptionManagerError.validateFailed(message: "Server returned non-zero status: \(status)"))
                                return
                            }
                        }
                    }
                    
                } catch {
                    completion(nil,SubscriptionManagerError.validatorError(rootError: error))
                    return
                }
                
            }
            completion(nil,SubscriptionManagerError.validateFailed(message: "Unable to validte receipt"))
        });
        
        task.resume()
    }
}
