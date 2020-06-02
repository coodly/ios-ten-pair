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

private typealias Dependencies = PersistenceConsumer & ContainerConsumer & UserRecordConsumer

internal class PushDeviceOperation: CloudKitRequest<Cloud.Device>, Dependencies {
    var persistence: CorePersistence!
    var insightContainer: CKContainer! {
        didSet {
            container = insightContainer
        }
    }
    var userRecordID: CKRecord.ID?
    
    private var pushed = [String]()

    override func performRequest() {
        Logging.log("Push device")
        
        guard userRecordID != nil else {
            Logging.log("No user record")
            self.finish()
            return
        }
        
        persistence.perform() {
            context in
            
            let push = context.devicesNeedingPush().compactMap({ $0.toCloud() })
            guard push.count > 0 else {
                Logging.log("No devices to push")
                self.finish()
                return
            }
            
            Logging.log("Pushing \(push)")
            self.pushed = push.compactMap({ $0.recordName })
            self.save(records: push, inDatabase: .public)
        }
    }
    
    override func handle(result: CloudResult<Cloud.Device>, completion: @escaping () -> ()) {
        persistence.write() {
            context in
            
            if let error = result.error {
                Logging.log("Push devices error: \(error)")
                
                let failed = context.devices(with: self.pushed)
                Logging.log("Mark push failure on \(failed.count) devices")
                failed.forEach({ $0.markSyncFailed() })
            } else {
                let names = result.records.compactMap({ $0.recordName })
                let pushed = context.devices(with: names)
                for record in result.records {
                    guard let device = pushed.first(where: { $0.recordName == record.recordName }) else {
                        continue
                    }
                    
                    device.recordData = record.recordData
                    device.markSyncNeed(false)
                }
            }
        }
        
        completion()
    }
}
