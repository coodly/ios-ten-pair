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
import CoreData

extension NSManagedObjectContext {
    internal func applications(with identifiers: Set<String>) -> [Application] {
        guard identifiers.count > 0 else {
            return []
        }
        
        let predicate = NSPredicate(format: "identifier IN %@", identifiers)
        let existing: [Application] =  fetch(predicate: predicate)
        if existing.count == identifiers.count {
            return existing
        }
        
        let missingIdentifiers = identifiers.subtracting(existing.map({ $0.identifier }))
        Logging.log("Missing \(missingIdentifiers.count) identifiers: \(missingIdentifiers.sorted())")
        let created: [Application] = missingIdentifiers.map() {
            id in
            
            let saved: Application = insertEntity()
            saved.identifier = id
            
            return saved
        }
        
        return existing + created
    }
    
    internal func fetchedControllerForApplications() -> NSFetchedResultsController<Application> {
        let sort = NSSortDescriptor(key: "identifier", ascending: true)
        return fetchedController(sort: [sort])
    }
}
