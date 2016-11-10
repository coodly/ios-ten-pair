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

@objc(Conversation)
public class Conversation: NSManagedObject {
    public override func awakeFromInsert() {
        lastMessageTime = Date()
        recordName = UUID().uuidString
    }
    
    func toCloud() -> CloudConversation {
        var cloud = CloudConversation()
        cloud.recordName = recordName
        cloud.recordData = recordData
        cloud.lastMessageTime = lastMessageTime
        cloud.snippet = snippet
        return cloud
    }
    
    func shouldFetchMessages() -> Bool {
        if hasUpdate {
            return true
        }
        
        return recordData != nil && messages?.count == 0
    }
}

extension Conversation {
    @NSManaged var recordName: String?
    @NSManaged var lastMessageTime: Date?
    @NSManaged var messages: Set<Message>?
    @NSManaged var snippet: String?
    @NSManaged var recordData: Data?
    @NSManaged var syncNeeded: Bool
    @NSManaged var syncFailed: Bool
    @NSManaged var hasUpdate: Bool
}
