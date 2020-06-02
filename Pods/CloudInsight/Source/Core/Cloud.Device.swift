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
import Puff

extension Cloud {
    internal struct Device: RemoteRecord {
        var recordName: String?
        var recordData: Data?
        
        var parent: CKRecord.ID?
        
        static var recordType: CKRecord.RecordType {
            return "Device"
        }
        
        var model: String?
        var osVersion: String?
        var appIdentifier: String?
        var modifiedAt: Date?
        var createdBy: CKRecord.ID?
        var createdOn: Date?
        
        mutating func loadFields(from record: CKRecord) -> Bool {
            model = record["model"] as? String
            osVersion = record["osVersion"] as? String
            appIdentifier = record["appIdentifier"] as? String
            
            modifiedAt = record.modificationDate
            createdBy = record.creatorUserRecordID
            createdOn = record.creationDate
            
            return true
        }
    }
}

extension Device {
    internal func toCloud() -> Cloud.Device? {
        var cloud = Cloud.Device()
        cloud.recordName = recordName
        cloud.recordData = recordData
        cloud.model = model
        cloud.osVersion = osVersion
        cloud.appIdentifier = Bundle.main.bundleIdentifier
        return cloud
    }
}


extension Cloud.Device: Timestamped {
    static var lastKnownKey: String {
        return "last-known-for-\(recordType)"
    }
}
