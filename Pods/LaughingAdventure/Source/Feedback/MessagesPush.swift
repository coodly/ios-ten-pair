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

import Foundation
import CoreData
import CoreDataPersistence

class MessagesPush: NSObject, PersistenceConsumer, NSFetchedResultsControllerDelegate, InjectionHandler {
    private lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Message push queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    var persistence: CorePersistence! {
        didSet {
            messagesController = persistence.mainContext.fetchedControllerForConversationsNeedingSync()
        }
    }
    private var messagesController: NSFetchedResultsController<Conversation>! {
        didSet {
            messagesController.delegate = self
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        queue.addOperation {
            Logging.log("Changes in conversations")
            let pushConversation = PushConversationsOperation()
            self.inject(into: pushConversation)
            
            let pushMessages = PushMessagesOperation()
            self.inject(into: pushMessages)
            pushMessages.addDependency(pushConversation)
            
            self.queue.addOperations([pushConversation, pushMessages], waitUntilFinished: false)
        }
    }
}
