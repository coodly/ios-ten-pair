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
import CoreDataPersistence

class FeedbackRefresh: InjectionHandler, PersistenceConsumer {
    var persistence: CorePersistence!
    
    public func refresh(completion: @escaping ((Bool) -> ())) {
        let op = PullConversationsOperation()
        inject(into: op)
        op.completionHandler = {
            success, _ in
            
            DispatchQueue.main.async {
                self.persistence.performInBackground() {
                    context in
                    
                    let hasUnseen = context.hasUnseenConversations()
                    completion(hasUnseen)
                }
            }
        }
        op.start()
    }
}
