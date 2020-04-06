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
    
    public func refresh(completion: @escaping ((Bool) -> ())) {
        let op = PullConversationsOperation()
        inject(into: op)
        let callback: ((Result<PullConversationsOperation, Error>) -> Void) = {
            _ in
            
            DispatchQueue.main.async {
                self.persistence.performInBackground() {
                    context in
                    
                    let hasUnseen = context.hasUnseenConversations()
                    completion(hasUnseen)
                }
            }
        }
        op.onCompletion(callback: callback)
        op.start()
    }
}
