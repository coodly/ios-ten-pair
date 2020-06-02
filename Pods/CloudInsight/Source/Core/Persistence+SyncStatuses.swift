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

private extension NSPredicate {
    static let syncNeeded = NSPredicate(format: "syncNeeded = YES")
    static let syncNotFailed = NSPredicate(format: "syncFailed = NO")
    static let syncable = NSCompoundPredicate(andPredicateWithSubpredicates: [.syncNeeded, .syncNotFailed])
}

extension NSManagedObjectContext {
    internal func fetchedControllerForSyncStatuses() -> NSFetchedResultsController<SyncStatus> {
        let sort = NSSortDescriptor(key: "syncNeeded", ascending: true)
        return fetchedController(predicate: .syncable, sort: [sort])
    }
    
    internal func resetFailedSyncs() {
        let predicate = NSPredicate(format: "syncFailed = YES")
        let failed: [SyncStatus] = fetch(predicate: predicate)
        Logging.log("Have \(failed.count) failed statuses")
        failed.forEach({ $0.syncFailed = false })
    }
}
