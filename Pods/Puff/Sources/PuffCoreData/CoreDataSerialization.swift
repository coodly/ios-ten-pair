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
import CoreData

#if canImport(PuffSerialization)
import PuffSerialization
#endif
#if canImport(PuffLogger)
import PuffLogger
#endif

@available(OSX 10.12, iOS 10, tvOS 10, *)
public class CoreDataSerialization<R: RemoteRecord & NSManagedObject>: RecordSerialization<R> {
    private let context: NSManagedObjectContext
    private let deserializeUpdatesRecordDetailsOnly: Bool
    public init(context: NSManagedObjectContext, deserializeUpdatesRecordDetailsOnly: Bool = false) {
        self.context = context
        self.deserializeUpdatesRecordDetailsOnly = deserializeUpdatesRecordDetailsOnly
        
        super.init()
    }
    
    public override func serialize(records: [R], in zone: CKRecordZone = .default()) -> [CKRecord] {
        return records.map({ serialize(entity: $0, in: zone) })
    }
    
    public override func deserialize(records: [CKRecord], from zone: CKRecordZone = .default()) -> [R] {
        var deserialized = [R]()
        context.performAndWait {
            let names = records.map({ $0.recordID.recordName })
            let existing: [R] = context.fetch(with: names)
            for record in records {
                let saved: R = existing.first(where: { $0.recordName == record.recordID.recordName }) ?? context.insertEntity()
                
                if let migration = zoneMigration, let zoned = saved as? CustomZoned, !migration.shouldLoad(entity: zoned, from: zone) {
                    continue
                }
                
                load(record: record, into: saved)
                
                if var zoned = saved as? CustomZoned {
                    zoned.zoneName = zone.zoneID.zoneName
                }
                
                deserialized.append(saved)
            }
        }
        
        return deserialized
    }
    
    private func load(record: CKRecord, into modified: R) {
        var local = modified
        
        if var stamped  = local as? Timestamped {
            stamped.modificationDate = record.modificationDate
        }
        
        local.recordName = record.recordID.recordName
        local.recordData = archive(record: record)
        
        if deserializeUpdatesRecordDetailsOnly {
            return
        }
        
        if let localTime = (local as? LocalModificationTimeChecked)?.localModificationTime, let remoteTime = record.modificationDate, localTime > remoteTime {
            Logging.log("Have local modification on \(R.entityName) \(local.recordName ?? "-"): l:\(localTime) vs r:\(remoteTime)")
            return
        }
        
        for (name, attribute) in R.entity().attributesByName {
            if PuffSystemAttributes.contains(name) {
                continue
            }
            
            if local is Timestamped, name == PuffSystemAttributeModificationDate {
                continue
            }
            
            if attribute.puffIgnored {
                continue
            }
                        
            switch attribute.attributeType {
            case .stringAttributeType,
                 .integer16AttributeType,
                 .integer32AttributeType,
                 .integer64AttributeType,
                 .booleanAttributeType,
                 .dateAttributeType,
                 .doubleAttributeType:
                local.setValue(record[name] ?? local.value(forKey: name) ?? attribute.defaultValue, forKey: name)
            case .binaryDataAttributeType:
                local.setValue(record.data(from: name) ?? local.value(forKey: name), forKey: name)
            default:
                let message = "Unhandled attribute type: \(attribute.attributeType)"
                assertionFailure(message)
                Logging.log(message)
            }
        }
        
        guard let cloudSerialized = modified as? CloudSerializedEntity else {
            return
        }
        
        for (name, relationship) in R.entity().relationshipsByName {
            guard cloudSerialized.shouldSerializeRelationship(named: name) else {
                continue
            }
            
            if let strings = record[name] as? [String], let loading = local as? RelationshipListLoading {
                loading.load(values: strings, on: name)
                continue
            }

            let mappedReferences: [CKRecord.Reference]
            if let reference = record[name] as? CKRecord.Reference {
                mappedReferences = [reference]
            } else if let references = record[name] as? [CKRecord.Reference] {
                mappedReferences = references
            } else {
                mappedReferences = []
            }
            
            guard mappedReferences.count > 0 else {
                continue
            }
            
            guard let destination = relationship.destinationEntity else {
                continue
            }
            
            guard destination.properties.first(where: { $0.name == PuffSystemAttributeRecordName }) != nil else {
                continue
            }

            let entities: [NSManagedObject] = mappedReferences.compactMap() {
                reference in
                
                if let entity = context.fetchEntity(named: destination.name!, withRecordName: reference.recordID.recordName) {
                    return entity
                } else {
                    Logging.log("No location destination for \(relationship.name) named \(reference.recordID.recordName)")
                    return nil
                }
            }

            if relationship.isToMany {
                local.setValue(Set(entities), forKey: name)
            } else {
                local.setValue(entities.first, forKey: name)
            }
        }
    }
    
    private func serialize(entity: R, in zone: CKRecordZone) -> CKRecord {
        let record: CKRecord
        if let existing = unarchiveRecord(entity: entity) {
            record = existing
        } else if let name = entity.recordName {
            record = CKRecord(recordType: R.recordType, recordID: CKRecord.ID(recordName: name, zoneID: zone.zoneID))
        } else {
            record = CKRecord(recordType: R.recordType, recordID: CKRecord.ID(recordName: UUID().uuidString, zoneID: zone.zoneID))
        }
        
        for (name, attribute) in entity.entity.attributesByName {
            if PuffSystemAttributes.contains(name) {
                continue
            }
            
            if name == PuffSystemAttributeModificationDate, entity is Timestamped {
                continue
            }
            
            if name == PuffSystemAttributeZoneName, entity is CustomZoned {
                continue
            }
            
            if attribute.puffIgnored {
                continue
            }
            
            switch attribute.attributeType {
            case .integer16AttributeType, .integer32AttributeType, .integer64AttributeType, .doubleAttributeType:
                record[name] = entity.value(forKey: name) as? NSNumber
            case .stringAttributeType:
                record[name] = entity.value(forKey: name) as? String
            case .booleanAttributeType:
                record[name] = NSNumber(booleanLiteral: entity.value(forKey: name) as? Bool ?? attribute.defaultValue as? Bool ?? false)
            case .dateAttributeType:
                record[name] = entity.value(forKey: name) as? Date
            case .binaryDataAttributeType:
                if let data = entity.value(forKey: name) as? Data, let file = createTempFile(with: data) {
                    record[name] = CKAsset(fileURL: file)
                } else {
                    Logging.log("Could not attach data from \(name) as CKAsset")
                }
            default:
                assertionFailure()
                print("Unhandled attribute type: \(attribute.attributeType)")
            }
        }
        
        guard let cloudSerialized = entity as? CloudSerializedEntity else {
            return record
        }
        
        for (name, _) in entity.entity.relationshipsByName {
            guard cloudSerialized.shouldSerializeRelationship(named: name) else {
                continue
            }
            
            if let synced = entity.value(forKey: name) as? RemoteRecord {
                record[name] = zonedReference(from: synced, fallback: zone)
                continue
            }

            if let set = entity.value(forKey: name) as? NSSet, let toListElements = Array(set) as? [StringListItem] {
                record[name] = toListElements.compactMap({ $0.stringValue() })
            }
            
            if let set = entity.value(forKey: name) as? NSSet, let relationshipRecords = Array(set) as? [RemoteRecord] {
                record[name] = relationshipRecords.map({ zonedReference(from: $0, fallback: zone) })
            }
        }
        
        return record
    }
    
    private func unarchiveRecord(entity: RemoteRecord) -> CKRecord? {
        guard let data = entity.recordData else {
            return nil
        }
        
        let coder = NSKeyedUnarchiver(forReadingWith: data)
        coder.requiresSecureCoding = true
        return CKRecord(coder: coder)
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
    
    private func zonedReference(from record: RemoteRecord, fallback: CKRecordZone) -> CKRecord.Reference {
        let zone: CKRecordZone
        if let zoned = record as? CustomZoned, zoned.zoneName.count > 0 {
            zone = CKRecordZone(zoneName: zoned.zoneName)
        } else {
            zone = fallback
        }
        
        return CKRecord.Reference(recordID: CKRecord.ID(recordName: record.recordName!, zoneID: zone.zoneID), action: .none)
    }
}

extension NSAttributeDescription {
    fileprivate var puffIgnored: Bool {
        if isTransient {
            return true
        }
        
        if let flag = userInfo?[PuffAttributeIgnored] as? String, let value = Bool(flag), value {
            return true
        }
        
        return false
    }
}
