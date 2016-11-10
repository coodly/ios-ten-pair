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
import CloudKit

public class SubscriptionCheck {
    private let recordType: String
    private let predicate: NSPredicate
    private let options: CKSubscriptionOptions
    private let desiredKeys: [String]
    private let deleteOthers: Bool
    public var container = CKContainer.default()
    
    public init(recordType: String, predicate: NSPredicate = NSPredicate(format: "TRUEPREDICATE"), options: CKSubscriptionOptions, desiredKeys: [String] = [], deleteOthers: Bool = false) {
        self.recordType = recordType
        self.predicate = predicate
        self.options = options
        self.desiredKeys = desiredKeys
        self.deleteOthers = deleteOthers
    }
    
    public func check() {
        Logging.log("Check subscriptions")
        
        let resultHandler: ([CKSubscription]?, Error?) -> () = {
            subscriptions, error in
            
            if let error = error as? NSError, let retryAfter = error.userInfo[CKErrorRetryAfterKey] as? TimeInterval {
                Logging.log("Error: \(error)")
                Logging.log("Will retry after \(retryAfter) seconds")
                runAfter(retryAfter) {
                    Logging.log("Try again")
                    self.check()
                }
                return
            } else if let error = error {
                Logging.log("Subscription check error: \(error)")
                return
            }
            
            guard let subs = subscriptions, subs.count > 0 else {
                Logging.log("No subscriptions. Will create")
                self.subscribe()
                return
            }
            
            var haveExisting = false
            for sub in subs {
                Logging.log("See subscription: \(sub)")
                if sub.recordType == self.recordType && sub.subscriptionOptions == self.options {
                    haveExisting = true
                } else if self.deleteOthers {
                    Logging.log("Will delete \(sub)")
                    
                    let deletionHandler: (String?, Error?) -> () = {
                        id, error in
                        
                        Logging.log("Deletion result: \(id) - \(error)")
                    }
                    
                    self.container.publicCloudDatabase.delete(withSubscriptionID: sub.subscriptionID, completionHandler: deletionHandler)
                }
            }
            
            if haveExisting {
                Logging.log("Have existing subscription")
                return
            }
            
            Logging.log("Had no subscriptions")
            self.subscribe()
        }

        container.publicCloudDatabase.fetchAllSubscriptions(completionHandler: resultHandler)
    }
    
    func subscribe() {
        Logging.log("Subscribe")
        let subscription = CKSubscription(recordType: recordType, predicate: predicate, options: options)
        let notificationInfo = CKNotificationInfo()
        #if os(iOS)
        notificationInfo.shouldSendContentAvailable = true
        #endif
        if desiredKeys.count > 0 {
            notificationInfo.desiredKeys = desiredKeys
        }
        subscription.notificationInfo = notificationInfo
        container.publicCloudDatabase.save(subscription) {
            subscription, error in
            
            Logging.log("Subscription result: \(subscription) - \(error)")
        }

    }
}
