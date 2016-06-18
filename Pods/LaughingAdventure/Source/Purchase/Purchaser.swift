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
    case Success
    case Cancelled
    case Failure
    case Defered
    case Restored
}

public protocol PurchaseMonitor: class {
    func purchase(result: PurchaseResult, forProduct identifier: String)
}

public class Purchaser: NSObject {
    public weak var passiveMonitor: PurchaseMonitor?
    public weak var activeMonitor: PurchaseMonitor?
    
    public func startMonitoring() {
        Logging.log("Start monitoring")
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
    
    public func purchase(product: SKProduct) {
        Logging.log("Purchase:\(product.productIdentifier)")
        let payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    public func restore() {
        Logging.log("restore purchases")
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    func monitor() -> PurchaseMonitor? {
        if let active = activeMonitor {
            return active
        }
        
        return passiveMonitor
    }
}

extension Purchaser: SKPaymentTransactionObserver {
    @objc public func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            var finishTransaction = false
            
            defer {
                if finishTransaction {
                    queue.finishTransaction(transaction)
                }
            }
            
            let notifyMonitor = monitor()
            let productIdentifier = transaction.payment.productIdentifier
            Logging.log("identifier: \(productIdentifier)")
            
            switch transaction.transactionState {
            // Transaction is being added to the server queue.
            case .Purchasing: Logging.log("Purchasing")
            case .Purchased: // Transaction is in queue, user has been charged.  Client should complete the transaction.
                Logging.log("Purchased")
                notifyMonitor?.purchase(.Success, forProduct: productIdentifier)
                finishTransaction = true
            case .Failed: // Transaction was cancelled or failed before being added to the server queue.
                Logging.log("Failed: \(transaction.error)")
                finishTransaction = true
                if let error = transaction.error where error.code == SKErrorCode.PaymentCancelled.rawValue {
                    notifyMonitor?.purchase(.Cancelled, forProduct: productIdentifier)
                } else {
                    notifyMonitor?.purchase(.Failure, forProduct: productIdentifier)
                }
            case .Restored: // Transaction was restored from user's purchase history.  Client should complete the transaction.
                Logging.log("Restored")
                finishTransaction = true
                notifyMonitor?.purchase(.Restored, forProduct: productIdentifier)
            case .Deferred: // The transaction is in the queue, but its final status is pending external action.
                Logging.log("Deferred")
                notifyMonitor?.purchase(.Cancelled, forProduct: productIdentifier)
            }
        }
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        Logging.log("Restore completed")
    }
    
    public func paymentQueue(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: NSError) {
        Logging.log("Restore failed with error: \(error)")
    }
}
