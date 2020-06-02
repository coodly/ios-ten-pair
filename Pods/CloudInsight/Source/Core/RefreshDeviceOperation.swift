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
import Puff
import CloudKit
import CoreDataPersistence

private typealias Dependencies = UserRecordConsumer & ContainerConsumer & PersistenceConsumer

internal class RefreshDeviceOperation: CloudKitRequest<Cloud.Device>, Dependencies {
    var userRecordID: CKRecord.ID?
    var insightContainer: CKContainer! {
        didSet {
            container = insightContainer
        }
    }
    var persistence: CorePersistence!
    
    private let deviceId: String
    internal init(deviceId: String) {
        self.deviceId = deviceId
    }
    
    override func performRequest() {
        let id = CKRecord.ID(recordName: deviceId)
        let predicate = NSPredicate(format: "recordID = %@", id)
        fetchFirst(predicate: predicate, inDatabase: .public)
    }
    
    override func handle(result: CloudResult<Cloud.Device>, completion: @escaping () -> ()) {
        persistence.write() {
            context in
            
            if let error = result.error {
                Logging.log("Fetch device error: \(error)")
            } else if let device = result.records.first {
                Logging.log("Fetched device: \(device)")
                context.refresh(device: device)
            }
        }
        
        completion()
    }
}
