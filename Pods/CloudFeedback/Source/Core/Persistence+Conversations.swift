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

import CoreData
import CloudKit
#if canImport(Combine)
import Combine
#endif

internal extension NSPredicate {
    @nonobjc static let needingSync: NSPredicate = {
        let syncNeeded = NSPredicate(format: "syncNeeded = YES")
        let syncNotFailed = NSPredicate(format: "syncFailed = NO")
        return NSCompoundPredicate(andPredicateWithSubpredicates: [syncNeeded, syncNotFailed])
    }()
}

internal extension NSManagedObjectContext {
    func fetchedControllerForConversations() -> NSFetchedResultsController<Conversation> {
        let sort = NSSortDescriptor(key: "lastMessageTime", ascending: false)
        return fetchedController(sort: [sort])
    }
    
    func namesForExistingConversations() -> [String] {
        return fetchAttribute(named: "recordName", on: Conversation.self)
    }
    
    func update(_ conversation: Cloud.Conversation) {
        let saved = existing(conversation) ?? insertEntity()
        
        let wasUpdated: Bool
        if let existing = saved.lastMessageTime {
            wasUpdated = conversation.lastMessageTime! > existing
        } else {
            wasUpdated = true
        }
        
        saved.recordName = conversation.recordName
        saved.recordData = conversation.recordData
        saved.lastMessageTime = conversation.lastMessageTime
        saved.snippet = conversation.snippet
        saved.syncNeeded = false
        saved.hasUpdate = wasUpdated
    }
    
    func removeConversations(withNames: [String]) {
        let predicate = NSPredicate(format: "recordName IN %@", withNames)
        let removed: [Conversation] = fetch(predicate: predicate, limit: nil)
        Logging.log("Remove \(removed.count) conversations")
        for r in removed {
            delete(r)
        }
    }
    
    private func existing(_ conversation: Cloud.Conversation) -> Conversation? {
        return fetchEntity(where: "recordName", hasValue: conversation.recordName!)
    }
    
    func fetchedControllerForConversationsNeedingSync() -> NSFetchedResultsController<Conversation> {
        let sort = NSSortDescriptor(key: "lastMessageTime", ascending: false)
        return fetchedController(predicate: .needingSync, sort: [sort])
    }
    
    func conversationsNeedingSync() -> [Conversation] {
        Logging.log("All conversations: \(count(instancesOf: Conversation.self))")
        Logging.log("Needing sync: \(count(instancesOf: Conversation.self, predicate: .needingSync))")
        return fetch(predicate: .needingSync, limit: nil)
    }
    
    func markSyncFailureOn(conversations: [String]) {
        let predicate = NSPredicate(format: "recordName IN %@", conversations)
        let failed: [Conversation] = fetch(predicate: predicate, limit: nil)
        for f in failed {
            f.syncFailed = true
        }
    }
    
    func conversation(for reference: CKRecord.Reference) -> Conversation? {
        return fetchEntity(where: "recordName", hasValue: reference.recordID.recordName)
    }
    
    func hasUnseenConversations() -> Bool {
        let predicate = NSPredicate(format: "hasUpdate = YES")
        return count(instancesOf: Conversation.self, predicate: predicate) > 0
    }
    
    var conversation: Conversation {
        if let existing: Conversation = fetchFirst() {
            return existing
        }
        
        let saved: Conversation = insertEntity()
        saved.recordName = UUID().uuidString
        return saved
    }
    
    @available(iOS 13.0, *)
    var unreadConversations: AnyPublisher<[Conversation], Never> {
        let predicate = NSPredicate(format: "hasUpdate = YES")
        return monitorEntities(of: Conversation.self, predicate: predicate, sort: [])
    }
}
