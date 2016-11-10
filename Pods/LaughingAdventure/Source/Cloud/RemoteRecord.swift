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

import CloudKit

public protocol RemoteRecord {
    var recordName: String? { get set }
    var recordData: Data? { get set }
    var parent: CKRecordID? { get set }
    static var recordType: String { get }

    init()
    
    mutating func loadFields(from record: CKRecord) -> Bool
    func referenceRepresentation() -> CKReference
}

public extension RemoteRecord {
    internal mutating func load(record: CKRecord) -> Bool {
        recordData = archive(record: record) as Data
        recordName = record.recordID.recordName
        parent = record.parent?.recordID
        return loadFields(from: record)
    }
    
    func referenceRepresentation() -> CKReference {
        return CKReference(recordID: CKRecordID(recordName: recordName!), action: .deleteSelf)
    }
    
    private func archive(record: CKRecord) -> NSMutableData {
        let archivedData = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: archivedData)
        archiver.requiresSecureCoding = true
        record.encodeSystemFields(with: archiver)
        archiver.finishEncoding()
        return archivedData
    }
    
    private func unarchiveRecord() -> CKRecord? {
        guard let data = recordData else {
            return nil
        }
        
        let coder = NSKeyedUnarchiver(forReadingWith: data)
        coder.requiresSecureCoding = true
        return CKRecord(coder: coder)
    }
    
    internal func recordRepresentation() -> CKRecord {
        let modified: CKRecord
        if let existing = unarchiveRecord() {
            modified = existing
        } else if let name = recordName {
            modified = CKRecord(recordType: Self.recordType, recordID: CKRecordID(recordName: name))
        } else {
            modified = CKRecord(recordType: Self.recordType)
        }
        
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            guard let label = child.label, label != "recordName" && label != "recordData" else {
                continue
            }
            
            if label == "parent", let value = child.value as? CKRecordID {
                modified.setParent(value)
            } else if let value = child.value as? NSString {
                modified[label] = value
            } else if let value = child.value as? NSNumber {
                modified[label] = value
            } else if let value = child.value as? Date {
                modified[label] = value as CKRecordValue
            } else if let value = child.value as? CLLocation {
                modified[label] = value
            } else if let value = child.value as? CKReference {
                modified[label] = value
            } else if let value = child.value as? [String] {
                modified[label] = value as CKRecordValue
            } else if let value = child.value as? [NSNumber] {
                modified[label] = value as CKRecordValue
            } else if let value = child.value as? [Date] {
                modified[label] = value as CKRecordValue
            } else if let value = child.value as? [CLLocation] {
                modified[label] = value as CKRecordValue
            } else if let value = child.value as? [CKReference] {
                modified[label] = value as CKRecordValue
            } else {
                Logging.log("Could not cast \(child) value")
            }
        }

        return modified
    }
}
