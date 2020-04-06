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

import CoreData

#if canImport(PuffLogger)
import PuffLogger
#endif

internal extension NSManagedObjectContext {
    func insertEntity<T: NSManagedObject>() -> T {
        return NSEntityDescription.insertNewObject(forEntityName: T.entityName, into: self) as! T
    }
    
    func fetch<T: NSManagedObject>(with names: [String]) -> [T] {
        let request: NSFetchRequest<T> = NSFetchRequest(entityName: T.entityName)
        request.predicate = NSPredicate(format: "recordName IN %@", names)
        
        do {
            return try fetch(request)
        } catch {
            Logging.log("Fetch \(T.entityName) failure. Error \(error)")
            return []
        }
    }
    
    func fetchEntity(named entityName: String, withRecordName recordName: String) -> NSManagedObject? {
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: entityName)
        request.predicate = NSPredicate(format: "recordName = %@", recordName)
        request.fetchLimit = 1

        do {
            return try fetch(request).first
        } catch {
            Logging.log("Fetch \(entityName) failure. Error \(error)")
            return nil
        }
    }
}
