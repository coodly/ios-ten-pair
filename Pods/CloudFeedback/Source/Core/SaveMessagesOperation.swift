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
import Puff
import CloudKit

internal class SaveMessagesOperation: CloudKitRequest<Cloud.Message> {
    internal var resultHandler: ((SaveMessagesResult) -> Void)?
    
    private let messages: [Cloud.Message]
    init(messages: [Cloud.Message], container: CKContainer) {
        self.messages = messages
        
        super.init()
        
        self.container = container
    }
    
    override func performRequest() {
        save(records: messages, inDatabase: .public)
    }
    
    override func handle(result: CloudResult<Cloud.Message>, completion: @escaping () -> ()) {
        if result.error != nil {
            Logging.log("Save failure")
            resultHandler?(.failure)
        } else {
            Logging.log("Success")
            resultHandler?(.success(result.records))
        }
        
        completion()
    }
}

