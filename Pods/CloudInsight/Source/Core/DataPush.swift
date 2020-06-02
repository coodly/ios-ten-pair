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
import CoreDataPersistence
import CoreData

private typealias Dependencies = PersistenceConsumer & InsightQueueConsumer

internal class DataPush: NSObject, Injector, Dependencies {
    var persistence: CorePersistence!
    var queue: OperationQueue!
    
    private var fetchedController: NSFetchedResultsController<SyncStatus>?
    
    internal func load() {
        Logging.log("Load data push")
        
        fetchedController = persistence.mainContext.fetchedControllerForSyncStatuses()
        fetchedController?.delegate = self
        checkPushNeeded()
    }
    
    private func checkPushNeeded() {
        Logging.log("Check push needed")
        
        var operations = [Operation]()
        operations.add(operation: PushDeviceOperation())
        operations.add(operation: PushEventsOperation())
        
        operations.forEach({ inject(into: $0) })
        queue.addOperations(operations, waitUntilFinished: false)
    }
}

extension DataPush: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        checkPushNeeded()
    }
}
