//
//  SimpleReceiptValidator.swift
//  Pods
//
//  Created by Paul Wilkinson on 7/11/16.
//
//

import Foundation

/** SimpleReceiptValidator implements the `ReceiptValidator` protocol.
    It passes the receipt data to a server for validation.
    The server contacts the Apple receipt validation service and simply returns the result as JSON 
    to the validator
*/
 

public class SimpleReceiptValidator: ReceiptValidator {
    
    /// The base address for the validation web service in the form 'https://server.domain/pathToScript.php'
    fileprivate let serverBase: String
    
    /// The application bundle that should be in the receipt
    fileprivate let targetBundle: String
    
    /// Initialise an instance `SimpleReceiptValidator`
    /// - parameter serverBase: The base address for the validation web service in the form 'https://server.domain/pathToScript.php'
    /// - parameter targetBundle: The application bundle that should be in the receipt
    public init(serverBase: String, targetBundle: String) {
        self.serverBase = serverBase
        self.targetBundle = targetBundle
    }
    
    /**
     Validate raw receipt data and return a valid `Receipt` or `Error` via the completion handler
     
     - parameter receipt: The raw receipt data that was retrieved from a `ReceiptProvider`
     - parameter forSubscriptionMonitor: The `SubscriptionMonitor` instance that is making this request
     - parameter completion: The `ValidationHandler` closure to be invoked with the validation result
       - parameter receipt: The `Receipt` that was parsed and validated
       - parameter error: The error, if any, that resulted from attempting to validate the receipt data.
     */

    public func validate(receipt: Data, forSubscriptionMonitor monitor: SubscriptionMonitor, completion: @escaping (_ receipt:Receipt?, _ error:Error?) -> (Void)) {
        
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
                                    if let receipt = Receipt(json: json) {
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
