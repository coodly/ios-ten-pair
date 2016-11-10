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

public enum CloudResult<T: RemoteRecord> {
    case success([T], [CKRecordID])
    case failure
}

open class CloudKitRequest<T: RemoteRecord>: ConcurrentOperation, CloudRequest {
    fileprivate var records = [T]()
    fileprivate var deleted = [CKRecordID]()
    
    public var container = CKContainer.default()
    
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
    
    fileprivate func handleResult(withCursor cursor: CKQueryCursor?, limit: Int? = nil, error: Error?, inDatabase db: UsedDatabase, retryClosure: @escaping () -> ()) {
        let finalizer: () -> ()
        var hadFailure = false
        if let cursor = cursor {
            finalizer = {
                self.records.removeAll()
                self.deleted.removeAll()
                self.continueWith(cursor, limit: limit, inDatabase: db)
            }
        } else {
            finalizer = {
                self.finish(hadFailure)
            }
        }
        
        if let error = error as? NSError, let retryAfter = error.userInfo[CKErrorRetryAfterKey] as? TimeInterval {
            Logging.log("Error: \(error)")
            Logging.log("Will retry after \(retryAfter) seconds")
            runAfter(retryAfter) {
                Logging.log("Try again")
                retryClosure()
            }
        } else if let error = error {
            Logging.log("Error: \(error)")
            hadFailure = true
            self.handle(result: .failure, completion: finalizer)
        } else {
            self.handle(result: .success(self.records, self.deleted), completion: finalizer)
        }
    }
}

public extension CloudKitRequest {
    public final func delete(record: T, inDatabase db: UsedDatabase = .private) {
        Logging.log("Delete \(record)")
        let deleted = CKRecordID(recordName: record.recordName!)
        
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [deleted])
        operation.modifyRecordsCompletionBlock = {
            saved, deleted, error in
            
            Logging.log("Saved: \(saved?.count)")
            Logging.log("Deleted: \(deleted?.count)")
            if let deleted = deleted {
                self.deleted.append(contentsOf: deleted)
            }

            self.handleResult(withCursor: nil, error: error, inDatabase: db) {
                self.delete(record: record, inDatabase: db)
            }
        }
        
        database(for: db).add(operation)
    }
}

public extension CloudKitRequest {
    public final func save(records: [T], delete: [CKRecordID] = [], inDatabase db: UsedDatabase = .private) {
        let toSave = records.map { $0.recordRepresentation() }
        
        let operation = CKModifyRecordsOperation(recordsToSave: toSave, recordIDsToDelete: delete)
        operation.modifyRecordsCompletionBlock = {
            saved, deleted, error in
            
            Logging.log("Saved: \(saved?.count)")
            Logging.log("Deleted: \(deleted?.count)")
            
            if let saved = saved {
                for s in saved {
                    var local = T()
                    if local.load(record: s) {
                        self.records.append(local)
                    }
                }
            }
            
            if let deleted = deleted {
                self.deleted.append(contentsOf: deleted)
            }
            
            self.handleResult(withCursor: nil, error: error, inDatabase: db) {
                self.save(records: records, inDatabase: db)
            }
        }
        
        database(for: db).add(operation)
    }
    
    public final func save(record: T, inDatabase db: UsedDatabase = .private) {
        save(records: [record], inDatabase: db)
    }
}

public extension CloudKitRequest {
    public final func fetch(predicate: NSPredicate = NSPredicate(format: "TRUEPREDICATE"), sort: [NSSortDescriptor] = [], limit: Int? = nil, pullAll: Bool = true, inDatabase db: UsedDatabase = .private) {
        let query = CKQuery(recordType: T.recordType, predicate: predicate)
        query.sortDescriptors = sort
        perform(query, limit: limit, pullAll: pullAll, inDatabase: db)
    }
    
    public final func fetchFirst(predicate: NSPredicate = NSPredicate(format: "TRUEPREDICATE"), sort: [NSSortDescriptor] = [], inDatabase db: UsedDatabase = .private) {
        fetch(predicate: predicate, sort: sort, limit: 1, pullAll: false, inDatabase: db)
    }
    
    private final func perform(_ query: CKQuery, limit: Int? = nil, pullAll: Bool, inDatabase db: UsedDatabase) {
        Logging.log("Fetch \(query.recordType)")
        
        let fetchOperation = CKQueryOperation(query: query)
        
        execute(fetchOperation, limit: limit, pullAll: pullAll, inDatabase: db) {
            self.perform(query, limit: limit, pullAll: pullAll, inDatabase: db)
        }
    }

    fileprivate func continueWith(_ cursor: CKQueryCursor, limit: Int?, inDatabase db: UsedDatabase) {
        Logging.log("Continue with cursor")
        let operation = CKQueryOperation(cursor: cursor)
        execute(operation, limit: limit, pullAll: true, inDatabase: db) {
            self.continueWith(cursor, limit: limit, inDatabase: db)
        }
    }
    
    private func execute(_ fetchOperation: CKQueryOperation, limit: Int?, pullAll: Bool, inDatabase db: UsedDatabase, retryClosure: @escaping () -> ()) {
        Logging.log("Run query operation")
        if let limit = limit {
            fetchOperation.resultsLimit = limit
        }

        fetchOperation.recordFetchedBlock = {
            record in
            
            var local = T()
            if local.load(record: record) {
                self.records.append(local)
            }
        }
        
        fetchOperation.queryCompletionBlock = {
            cursor, error in
            
            if self.isCancelled {
                self.finish()
                return
            }
            
            Logging.log("Completion: \(cursor) - \(error)")
            Logging.log("Have \(self.records.count) records")
            
            let usedCursor = pullAll ? cursor : nil
            
            self.handleResult(withCursor: usedCursor, limit: limit, error: error, inDatabase: db, retryClosure: retryClosure)
        }
        
        database(for: db).add(fetchOperation)
    }
}
