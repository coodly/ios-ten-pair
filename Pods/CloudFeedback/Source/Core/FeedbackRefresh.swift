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
import CoreDataPersistence

class FeedbackRefresh: FeedbackInjector, PersistenceConsumer {
    var persistence: CorePersistence!
    private lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .utility
        return queue
    }()
    
    public func refresh(completion: @escaping ((Bool) -> ())) {
        pullConversations(completion: completion)
    }
    
    private func pullConversations(completion: @escaping ((Bool) -> Void)) {
        Logging.log("Pull coversations")
        let op = PullConversationsOperation()
        inject(into: op)
        let callback: ((Result<PullConversationsOperation, Error>) -> Void) = {
            result in
            
            switch result {
            case .failure(let error):
                Logging.log("Pull error \(error)")
                DispatchQueue.main.async() {
                    completion(false)
                }
            case .success(_):
                self.pullMessages(completion: completion)
            }
        }
        op.onCompletion(callback: callback)
        queue.addOperation(op)
    }
    
    private func pullMessages(completion: @escaping ((Bool) -> Void)) {
        Logging.log("Pull messages")
        persistence.performInBackground() {
            context in
            
            let conversations: [Conversation] = context.fetch()
            guard conversations.count > 0 else {
                Logging.log("No conversations")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            Logging.log("Pull messages in \(conversations.count) conversations")
            var operations: [Operation] = conversations.map({ PullMessagesOperation(for: $0) })
            operations.forEach({ self.inject(into: $0) })
            
            let finalise = BlockOperation() {
                self.persistence.performInBackground() {
                    context in
                    
                    let hasUnseen = context.hasUnseenConversations()
                    DispatchQueue.main.async {
                        completion(hasUnseen)
                    }
                }
            }
            
            operations.forEach({ finalise.addDependency($0) })
            operations.append(finalise)
            self.queue.addOperations(operations, waitUntilFinished: false)
        }
    }
}
