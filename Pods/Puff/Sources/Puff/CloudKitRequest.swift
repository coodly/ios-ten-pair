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

#if canImport(PuffSerialization)
import PuffSerialization
#endif
#if canImport(PuffLogger)
import PuffLogger
#endif

public enum UsedDatabase {
    case `public`
    case `private`
}

public struct CloudResult<T: RemoteRecord> {
    public let records: [T]
    public let deleted: [CKRecord.ID]
    public let hasMore: Bool
    public let error: Error?
}

open class CloudKitRequest<T: RemoteRecord>: ConcurrentOperation {
    fileprivate var records = [T]()
    fileprivate var deleted = [CKRecord.ID]()
    
    public var container = CKContainer.default()
    public var zone = CKRecordZone.default()
    
    public private(set) var cursor: CKQueryOperation.Cursor?
    
    public lazy var serialization: RecordSerialization<T> = StandardSerialization<T>()
    
    public override init() {

    }
    
    public final override func main() {
        Logging.log("Start \(T.self)")
        performRequest()
    }
    
    open func performRequest() {
        Logging.log("Override: \(#function)")
    }
    
    open func handle(result: CloudResult<T>, completion: @escaping () -> ()) {
        Logging.log("Handle result \(result)")
        completion()
    }
    
    fileprivate func database(for type: UsedDatabase) -> CKDatabase {
        switch type {
        case .public:
            return container.publicCloudDatabase
        case .private:
            return container.privateCloudDatabase
        }
    }
    
    fileprivate func handleResult(with cursor: CKQueryOperation.Cursor?, desiredKeys: [String]?, limit: Int? = nil, error: Error?, inDatabase db: UsedDatabase, retryClosure: @escaping () -> ()) {
        let finalizer: () -> ()
        if let cursor = cursor {
            finalizer = {
                self.records.removeAll()
                self.deleted.removeAll()
                self.nextBatch(using: cursor, desiredKeys: desiredKeys, limit: limit, inDatabase: db)
            }
        } else {
            finalizer = {
                self.finish(error)
            }
        }
        
        if let error = error as? CKError, let seconds = error.retryAfterSeconds {
            Logging.log("Error: \(error)")
            Logging.log("Will retry after \(seconds) seconds")
            run(after: seconds) {
                Logging.log("Try again")
                retryClosure()
            }
        } else {
            if let error = error {
                Logging.log("Request error \(error)")
            }
            self.handle(result: CloudResult(records: self.records, deleted: self.deleted, hasMore: cursor != nil, error: error), completion: finalizer)
        }
    }
    
    private func run(after seconds: TimeInterval, onQueue queue: DispatchQueue = DispatchQueue.main, closure: @escaping () -> ()) {
        let milliseconds = Int(seconds * 1000.0)
        queue.asyncAfter(deadline: .now() + .milliseconds(milliseconds), execute: closure)
    }
}

public extension CloudKitRequest {
    final func delete(record: T, inDatabase db: UsedDatabase = .private) {
        Logging.log("Delete \(record)")
        let deleted = CKRecord.ID(recordName: record.recordName!, zoneID: zone.zoneID)
        
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [deleted])
        operation.modifyRecordsCompletionBlock = {
            saved, deleted, error in
            
            Logging.log("Saved: \(String(describing: saved?.count))")
            Logging.log("Deleted: \(String(describing: deleted?.count))")
            if let deleted = deleted {
                self.deleted.append(contentsOf: deleted)
            }

            self.handleResult(with: nil, desiredKeys: nil, error: error, inDatabase: db) {
                self.delete(record: record, inDatabase: db)
            }
        }
        
        database(for: db).add(operation)
    }
}

extension CloudKitRequest {
    public final func save(records: [T], delete: [CKRecord.ID] = [], inDatabase db: UsedDatabase = .private) {
        let toSave = serialization.serialize(records: records, in: zone)
        
        let operation = CKModifyRecordsOperation(recordsToSave: toSave, recordIDsToDelete: delete)
        operation.modifyRecordsCompletionBlock = {
            saved, deleted, error in
            
            Logging.log("Saved: \(String(describing: saved?.count))")
            Logging.log("Deleted: \(String(describing: deleted?.count))")
            
            if let saved = saved {
                let local = self.serialization.deserialize(records: saved, from: self.zone)
                self.records.append(contentsOf: local)
            }
            
            if let deleted = deleted {
                self.deleted.append(contentsOf: deleted)
            }
            
            self.handleResult(with: nil, desiredKeys: nil, error: error, inDatabase: db) {
                self.save(records: records, delete: delete, inDatabase: db)
            }
        }
        
        database(for: db).add(operation)
    }
    
    public final func save(record: T, inDatabase db: UsedDatabase = .private) {
        save(records: [record], inDatabase: db)
    }
}

public extension CloudKitRequest {
    final func fetch(recordType: CKRecord.RecordType = T.recordType, predicate: NSPredicate = NSPredicate(format: "TRUEPREDICATE"), desiredKeys: [String]? = nil, sort: [NSSortDescriptor] = [], limit: Int? = nil, pullAll: Bool = true, inDatabase db: UsedDatabase = .private) {
        let query = CKQuery(recordType: recordType, predicate: predicate)
        query.sortDescriptors = sort
        perform(query, desiredKeys: desiredKeys, limit: limit, pullAll: pullAll, inDatabase: db)
    }
    
    final func fetchFirst(predicate: NSPredicate = NSPredicate(format: "TRUEPREDICATE"), desiredKeys: [String]? = nil, sort: [NSSortDescriptor] = [], inDatabase db: UsedDatabase = .private) {
        fetch(predicate: predicate, desiredKeys: desiredKeys, sort: sort, limit: 1, pullAll: false, inDatabase: db)
    }
    
    private final func perform(_ query: CKQuery, desiredKeys: [String]?, limit: Int? = nil, pullAll: Bool, inDatabase db: UsedDatabase) {
        Logging.log("Fetch \(query.recordType)")
        
        let fetchOperation = CKQueryOperation(query: query)
        
        execute(fetchOperation, desiredKeys: desiredKeys, limit: limit, pullAll: pullAll, inDatabase: db) {
            self.perform(query, desiredKeys: desiredKeys, limit: limit, pullAll: pullAll, inDatabase: db)
        }
    }

    func nextBatch(using cursor: CKQueryOperation.Cursor, desiredKeys: [String]? = nil, limit: Int?, pullAll: Bool = true, inDatabase db: UsedDatabase) {
        Logging.log("Continue with cursor")
        let operation = CKQueryOperation(cursor: cursor)
        execute(operation, desiredKeys: desiredKeys, limit: limit, pullAll: pullAll, inDatabase: db) {
            self.nextBatch(using: cursor, desiredKeys: desiredKeys, limit: limit, inDatabase: db)
        }
    }
    
    private func execute(_ fetchOperation: CKQueryOperation, desiredKeys: [String]?, limit: Int?, pullAll: Bool, inDatabase db: UsedDatabase, retryClosure: @escaping () -> ()) {
        Logging.log("Run query operation")
        if let limit = limit {
            fetchOperation.resultsLimit = limit
        }
        fetchOperation.desiredKeys = desiredKeys
        fetchOperation.zoneID = zone.zoneID
        
        fetchOperation.recordFetchedBlock = {
            record in
            
            if let local = self.serialization.deserialize(records: [record], from: self.zone).first {
                self.records.append(local)
            }
        }
        
        fetchOperation.queryCompletionBlock = {
            cursor, error in
            
            if self.isCancelled {
                self.finish()
                return
            }
            
            Logging.log("Completion: \(String(describing: cursor)) - \(String(describing: error))")
            Logging.log("Have \(self.records.count) records")
            
            self.cursor = cursor
            
            let usedCursor = pullAll ? cursor : nil
            
            self.handleResult(with: usedCursor, desiredKeys: desiredKeys, limit: limit, error: error, inDatabase: db, retryClosure: retryClosure)
        }
        
        database(for: db).add(fetchOperation)
    }
}
