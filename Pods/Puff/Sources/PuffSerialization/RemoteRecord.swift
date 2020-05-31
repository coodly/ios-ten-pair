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

#if canImport(PuffLogger)
import PuffLogger
#endif

public protocol RemoteRecord {
    var recordName: String? { get set }
    var recordData: Data? { get set }
    var parent: CKRecord.ID? { get set }
    static var recordType: CKRecord.RecordType { get }

    init()
    
    mutating func loadFields(from record: CKRecord) -> Bool
    func referenceRepresentation(action: CKRecord.Reference.Action) -> CKRecord.Reference
}

public extension RemoteRecord {
    internal mutating func load(record: CKRecord) -> Bool {
        recordData = archive(record: record) as Data
        recordName = record.recordID.recordName
        if #available(iOS 10, tvOS 10, macOS 10.12, *) {
            parent = record.parent?.recordID
        }
        return loadFields(from: record)
    }
    
    func referenceRepresentation(action: CKRecord.Reference.Action = .deleteSelf) -> CKRecord.Reference {
        let zone: CKRecordZone
        if let custom = self as? CustomZoned {
            zone = CKRecordZone(zoneName: custom.zoneName)
        } else {
            zone = .default()
        }
        return CKRecord.Reference(recordID: CKRecord.ID(recordName: recordName!, zoneID: zone.zoneID), action: action)
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
    
    internal func recordRepresentation(in zone: CKRecordZone = .default()) -> CKRecord {
        let modified: CKRecord
        if let existing = unarchiveRecord() {
            modified = existing
        } else if let name = recordName {
            modified = CKRecord(recordType: Self.recordType, recordID: CKRecord.ID(recordName: name, zoneID: zone.zoneID))
        } else {
            modified = CKRecord(recordType: Self.recordType, recordID: CKRecord.ID(recordName: UUID().uuidString, zoneID: zone.zoneID))
        }
        
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            guard let label = child.label, label != "recordName" && label != "recordData" else {
                continue
            }
            
            if #available(iOS 10, tvOS 10, macOS 10.12, *), label == "parent", let value = child.value as? CKRecord.ID {
                modified.setParent(value)
            } else if let value = child.value as? NSString {
                modified[label] = value
            } else if let value = child.value as? NSNumber {
                modified[label] = value
            } else if let value = child.value as? Date {
                modified[label] = value as CKRecordValue
            } else if let value = child.value as? CLLocation {
                modified[label] = value
            } else if let value = child.value as? CKRecord.Reference {
                modified[label] = value
            } else if let value = child.value as? [String] {
                modified[label] = value as CKRecordValue
            } else if let value = child.value as? [NSNumber] {
                modified[label] = value as CKRecordValue
            } else if let value = child.value as? [Date] {
                modified[label] = value as CKRecordValue
            } else if let value = child.value as? [CLLocation] {
                modified[label] = value as CKRecordValue
            } else if let value = child.value as? [CKRecord.Reference] {
                modified[label] = value as CKRecordValue
            } else if let value = child.value as? Data, let file = createTempFile(with: value) {
                modified[label] = CKAsset(fileURL: file)
            } else {
                //Logging.log("Could not cast \(child) value")
            }
        }

        return modified
    }
    
    private func createTempFile(with data: Data) -> URL? {
        let tmpDir = URL(fileURLWithPath: NSTemporaryDirectory())
        try? FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
        
        let file = tmpDir.appendingPathComponent(ProcessInfo().globallyUniqueString)
        do {
            try data.write(to: file, options: .atomic)
            return file
        } catch {
            Logging.log("Asset file write failed: \(error)")
            return nil
        }
    }
}
