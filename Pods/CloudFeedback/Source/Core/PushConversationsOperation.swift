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
import CloudKit
import CoreDataPersistence
import Puff

internal class PushConversationsOperation: CloudKitRequest<Cloud.Conversation>, PersistenceConsumer, FeedbackContainerConsumer {
    var persistence: CorePersistence!
    var feedbackContainer: CKContainer! {
        didSet {
            container = feedbackContainer
        }
    }
    
    private var names: [String]!
    
    override func performRequest() {
        persistence.performInBackground() {
            context in
            
            let toPush = context.conversationsNeedingSync()
            if toPush.count == 0 {
                Logging.log("No conversations to push")
                self.finish()
                return
            }
            
            var pushed = [Cloud.Conversation]()
            for c in toPush {
                pushed.append(c.toCloud())
            }
            
            self.names = pushed.map({ $0.recordName! })
            
            Logging.log("Will push \(pushed.count) conversations")
            
            self.save(records: pushed, inDatabase: .public)
        }
    }
    
    override func handle(result: CloudResult<Cloud.Conversation>, completion: @escaping () -> ()) {
        let save: ContextClosure = {
            context in
            
            if result.error != nil {
                context.markSyncFailureOn(conversations: self.names)
                self.names = []
            } else {
                for c in result.records {
                    context.update(c)
                }
            }
        }
        persistence.performInBackground(task: save, completion: completion)
    }
}
