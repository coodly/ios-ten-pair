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

import CloudKit

public let PuffSystemAttributeRecordName = "recordName"
public let PuffSystemAttributes = [PuffSystemAttributeRecordName, "recordData"]
public let PuffSystemAttributeModificationDate = "modificationDate"
public let PuffSystemAttributeZoneName = "zoneName"
public let PuffAttributeIgnored = "puff-ignored"

open class RecordSerialization<R: RemoteRecord> {
    public var zoneMigration: CustomZoneMigration?
    
    public init() {
        
    }
    
    open func serialize(records: [R], in zone: CKRecordZone) -> [CKRecord] {
        fatalError()
    }
    
    open func deserialize(records: [CKRecord], from zone: CKRecordZone) -> [R] {
        fatalError()
    }
    
    public func archive(record: CKRecord) -> Data {
        let archivedData = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: archivedData)
        archiver.requiresSecureCoding = true
        record.encodeSystemFields(with: archiver)
        archiver.finishEncoding()
        return archivedData as Data
    }
}
