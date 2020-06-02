/*
 * Copyright 2018 Coodly LLC
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

extension Cloud {
    internal struct Event: RemoteRecord {
        var recordName: String?
        var recordData: Data?
        
        var parent: CKRecord.ID?
        
        static var recordType: String {
            return "Event"
        }
        
        var device: String?
        var name: String?
        var time: Date?
        var values: String?
        var modifiedAt: Date?
        var createdBy: CKRecord.ID?
        
        mutating func loadFields(from record: CKRecord) -> Bool {
            device = record["device"] as? String
            name = record["name"] as? String
            time = record["time"] as? Date
            values = record["values"] as? String
            
            modifiedAt = record.modificationDate
            createdBy = record.creatorUserRecordID
            
            return true
        }
    }
}

extension Event {
    internal func toCloud() -> Cloud.Event {
        var event = Cloud.Event()
        event.recordName = recordName
        event.device = deviceIdentifier
        event.time = time
        event.name = name
        event.values = values
        return event
    }
}

extension Cloud.Event: Timestamped {
    static var lastKnownKey: String {
        return "last-known-for-\(recordType)"
    }
}
