/*
 * Copyright 2017 Coodly LLC
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

import CloudKit
import Puff

internal class FetchConversationsOperation: CloudKitRequest<Cloud.Conversation> {
    internal var progress: ((FetchConversationsProgress) -> Void)!
    
    private let since: Date
    
    init(since: Date, in container: CKContainer) {
        self.since = since
        
        super.init()
        
        self.container = container
    }
    
    override func performRequest() {
        let sort = NSSortDescriptor(key: "modificationDate", ascending: true)
        let timePredicate = NSPredicate(format: "modificationDate >= %@", since as NSDate)
        
        fetch(predicate: timePredicate, sort: [sort], pullAll: true, inDatabase: .public)
    }
    
    override func handle(result: CloudResult<Cloud.Conversation>, completion: @escaping () -> ()) {
        if result.error != nil {
            Logging.log("Fetch failed")
        } else {
            Logging.log("Pulled \(result.records.count) conversations")
            progress(.fetched(result.records))
        }
        
        completion()
    }
}
