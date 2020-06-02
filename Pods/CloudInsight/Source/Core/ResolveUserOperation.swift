/*
 * Copyright 2019 Coodly LLC
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

private typealias Dependencies = ContainerConsumer

internal class ResolveUserOperation: ConcurrentOperation, Dependencies {
    var insightContainer: CKContainer!
    
    override func main() {
        checkAccountStatus()
    }
    
    private func checkAccountStatus() {
        Logging.log("Check account status")
        insightContainer.accountStatus() {
            status, error in
            
            Logging.log("Account status: \(status.rawValue) - \(String(describing: error))")
            Logging.log("Available: \(status == .available)")
            
            guard status == .available else {
                Logging.log("CloudKit not available")
                self.finish()
                return
            }
            
            self.fetchUserRecord()
        }
    }
    
    private func fetchUserRecord() {
        Logging.log("Fetch user record")
        insightContainer.fetchUserRecordID() {
            recordId, error in
            
            Logging.log("Fetched: \(String(describing: recordId?.recordName)) - error \(String(describing: error))")

            if let error = error {
                Logging.log("Fetch user record error \(error)")
                self.finish(error)
            } else {
                Injection.shared.userRecordID = recordId
                self.finish()
            }
        }
    }
}
