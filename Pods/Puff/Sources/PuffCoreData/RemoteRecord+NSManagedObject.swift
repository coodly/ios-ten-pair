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
import CoreData
import CloudKit

#if canImport(PuffSerialization)
import PuffSerialization
#endif

// TODO jaanus: is this used?
public extension RemoteRecord where Self: NSManagedObject {
    static var recordType: String {
        return entityName
    }
    
    var parent: CKRecord.ID? {
        get {
            fatalError()
        }
        set {
            fatalError()
        }
    }
    
    func loadFields(from record: CKRecord) -> Bool {
        return true
    }
    
    @available(OSX 10.11, iOS 9, *)
    internal func recordRepresentation() -> CKRecord? {
        let record = CKRecord(recordType: Self.recordType)
        
        for (name, attribute) in entity.attributesByName {
            if PuffSystemAttributes.contains(name) {
                continue
            }
            
            switch attribute.attributeType {
            case .integer16AttributeType, .integer32AttributeType, .integer64AttributeType:
                record[name] = value(forKey: name) as? NSNumber
            case .stringAttributeType:
                record[name] = value(forKey: name) as? String
            case .booleanAttributeType:
                record[name] = NSNumber(booleanLiteral: value(forKey: name) as? Bool ?? attribute.defaultValue as? Bool ?? false)
            default:
                assertionFailure()
                print("Unhandled attribute type: \(attribute.attributeType)")
            }
        }
        
        return record
    }
}
