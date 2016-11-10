/*
 * Copyright 2016 Coodly LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
import StoreKit

public enum PurchaseResult {
    case success
    case cancelled
    case failure
    case defered
    case restored
    case notAllowed
}

public protocol PurchaseMonitor: class {
    func purchaseResult(_ result: PurchaseResult, for identifier: String)
}

public typealias ProductsResponse = ([SKProduct], [String]) -> ()

public class Storefront: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    private var requests = [SKProductsRequest: ProductsResponse]()

    public weak var passiveMonitor: PurchaseMonitor?
    public weak var activeMonitor: PurchaseMonitor?

    override public init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    public func retrieve(products: [String], completion: @escaping ProductsResponse) {
        Logging.log("Retrieve products: \(products)")
        let request = SKProductsRequest(productIdentifiers: Set(products))
        request.delegate = self
        requests[request] = completion
        request.start()
    }
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        Logging.log("Retrieved: \(response.products.count). Invalid \(response.invalidProductIdentifiers)")
        guard let completion = requests.removeValue(forKey: request) else {
            return
        }
        
        completion(response.products, response.invalidProductIdentifiers)
    }
    
    public func purchase(_ product: SKProduct) {
        Logging.log("Purchase:\(product.productIdentifier)")
        guard SKPaymentQueue.canMakePayments() else {
            monitor()?.purchaseResult(.notAllowed, for: product.productIdentifier)
            return
        }
        
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    public func restore() {
        Logging.log("restore purchases")
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func monitor() -> PurchaseMonitor? {
        if let active = activeMonitor {
            return active
        }
        
        return passiveMonitor
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            var finishTransaction = false
            
            defer {
                if finishTransaction {
                    queue.finishTransaction(transaction)
                }
            }
            
            let notifyMonitor = monitor()
            let productIdentifier = transaction.payment.productIdentifier
            if notifyMonitor == nil {
                Logging.log("No monitor set")
            }
            Logging.log("identifier: \(productIdentifier)")
            
            switch transaction.transactionState {
            // Transaction is being added to the server queue.
            case .purchasing: Logging.log("Purchasing")
            case .purchased: // Transaction is in queue, user has been charged.  Client should complete the transaction.
                Logging.log("Purchased")
                notifyMonitor?.purchaseResult(.success, for: productIdentifier)
                finishTransaction = true
            case .failed: // Transaction was cancelled or failed before being added to the server queue.
                Logging.log("Failed: \(transaction.error)")
                finishTransaction = true
                if let error = transaction.error as? NSError, error.code == SKError.paymentCancelled.rawValue {
                    notifyMonitor?.purchaseResult(.cancelled, for: productIdentifier)
                } else {
                    notifyMonitor?.purchaseResult(.failure, for: productIdentifier)
                }
            case .restored: // Transaction was restored from user's purchase history.  Client should complete the transaction.
                Logging.log("Restored")
                finishTransaction = true
                notifyMonitor?.purchaseResult(.restored, for: productIdentifier)
            case .deferred: // The transaction is in the queue, but its final status is pending external action.
                Logging.log("Deferred")
                notifyMonitor?.purchaseResult(.cancelled, for: productIdentifier)
            }
        }
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        Logging.log("Restore completed")
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        Logging.log("Restore failed with error: \(error)")
    }
}
