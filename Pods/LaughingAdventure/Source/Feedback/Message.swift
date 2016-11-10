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

@objc(Message)
internal class Message: NSManagedObject {
    override func awakeFromInsert() {
        recordName = UUID().uuidString
    }
    
    func toCloud() -> CloudMessage {
        var cloud = CloudMessage()
        cloud.recordName = recordName
        cloud.recordData = recordData
        cloud.body = body
        cloud.postedAt = postedAt
        cloud.conversation = conversation.toCloud().referenceRepresentation()
        return cloud
    }
}

extension Message {
    @NSManaged var body: String?
    @NSManaged var conversation: Conversation
    @NSManaged var postedAt: Date
    @NSManaged var recordData: Data?
    @NSManaged var recordName: String?
    @NSManaged var syncNeeded: Bool
    @NSManaged var syncFailed: Bool
    @NSManaged var sentBy: String?
}
