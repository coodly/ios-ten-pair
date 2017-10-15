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

internal class PullMessagesOperation: CloudKitRequest<CloudMessage>, PersistenceConsumer, FeedbackContainerConsumer {
    var persistence: CorePersistence!
    var feedbackContainer: CKContainer! {
        didSet {
            container = feedbackContainer
        }
    }
    
    private let pullMessagesFor: Conversation
    init(for conversation: Conversation) {
        pullMessagesFor = conversation
    }
    
    override func performRequest() {
        persistence.perform() {
            context in
            
            let conversation = context.inCurrentContext(entity: self.pullMessagesFor)
            let reference = conversation.toCloud().referenceRepresentation()
            let predicate = NSPredicate(format: "conversation = %@", reference)
            self.fetch(predicate: predicate, inDatabase: .public)
        }
    }
    
    override func handle(result: CloudResult<CloudMessage>, completion: @escaping () -> ()) {
        let save: ContextClosure = {
            context in
            
            switch result {
            case .failure:
                Logging.log("Pull masseges failed")
            case .success(let messages, _):
                for m in messages {
                    context.update(message: m)
                }
                
                let conversation = context.inCurrentContext(entity: self.pullMessagesFor)
                conversation.hasUpdate = false
            }
        }
        
        persistence.performInBackground(task: save, completion: completion)
    }
}
