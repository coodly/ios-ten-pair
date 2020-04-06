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
import CloudKit
import CoreDataPersistence
import Puff

internal class PushMessagesOperation: CloudKitRequest<Cloud.Message>, PersistenceConsumer, FeedbackContainerConsumer, PlatformConsumer {
    var persistence: CorePersistence!
    var feedbackContainer: CKContainer! {
        didSet {
            container = feedbackContainer
        }
    }
    var platform: String!
    private var messages: [Message]?
    
    override func performRequest() {
        persistence.performInBackground() {
            context in
            
            let messages = context.messagesNeedingPush()
            self.messages = messages
            if messages.count == 0 {
                Logging.log("No messages to push")
                self.finish()
                return
            }
            
            Logging.log("Will push \(messages.count) messages")
            
            var saved = [Cloud.Message]()
            for message in messages {
                var cloud = message.toCloud()
                cloud.platform = self.platform
                saved.append(cloud)
            }
            
            self.save(records: saved, inDatabase: .public)
        }
    }
    
    override func handle(result: CloudResult<Cloud.Message>, completion: @escaping () -> ()) {
        let save: ContextClosure = {
            context in
            
            let messages = context.inCurrentContext(entities: self.messages!)
            
            if result.error != nil {
                for m in messages {
                    m.syncFailed = true
                }
            } else {
                for m in result.records {
                    context.update(message: m)
                }
            }
        }
        
        persistence.performInBackground(task: save, completion: completion)
    }
}
