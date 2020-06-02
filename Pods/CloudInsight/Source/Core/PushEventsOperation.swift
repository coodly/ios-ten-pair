/*
 * Copyright 2019 Coodly LLC
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
import Puff
import CloudKit

private typealias Dependencies = PersistenceConsumer & ContainerConsumer & UserRecordConsumer

internal class PushEventsOperation: CloudKitRequest<Cloud.Event>, Dependencies {
    var persistence: CorePersistence!
    var insightContainer: CKContainer! {
        didSet {
            container = insightContainer
        }
    }
    var userRecordID: CKRecord.ID?
    
    private var pushed = [String]()

    override func performRequest() {
        Logging.log("Push events")

        guard userRecordID != nil else {
            Logging.log("No user record")
            self.finish()
            return
        }

        persistence.perform() {
            context in
            
            let events = context.eventsNeedingPush().map({ $0.toCloud() })
            guard events.count > 0 else {
                Logging.log("No events to push")
                self.finish()
                return
            }
            
            Logging.log("Pushing \(events)")
            self.pushed = events.compactMap({ $0.recordName })
            self.save(records: events, inDatabase: .public)
        }
    }
    
    override func handle(result: CloudResult<Cloud.Event>, completion: @escaping () -> ()) {
        persistence.write() {
            context in
            
            let saved = result.records.compactMap({ $0.recordName })
            context.remove(events: saved)
            
            let notSaved = self.pushed.filter({ !saved.contains($0) })
            guard notSaved.count > 0 else {
                return
            }
            
            Logging.log("Mark failure on \(notSaved.count) events")
            context.markFailure(on: notSaved)
            
            guard let cloudError = result.error as? CKError, let partial = cloudError.partialErrorsByItemID as? [CKRecord.ID: CKError] else {
                return
            }
            
            var conflicted = [String]()
            for (name, error) in partial {
                guard error.code == CKError.Code.serverRecordChanged else {
                    Logging.log("Unknown error \(error.code) on \(name.recordName)")
                    continue
                }
            
                conflicted.append(name.recordName)
            }
            Logging.log("Remove conflict events: \(conflicted)")
            context.remove(events: conflicted)
        }
        
        completion()
    }
}
