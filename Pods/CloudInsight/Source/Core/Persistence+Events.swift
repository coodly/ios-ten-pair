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
import CoreData

extension NSManagedObjectContext {
    internal func eventsNeedingPush() -> [Event] {
        return fetch(predicate: .needsSync)
    }
    
    internal func remove(events named: [String]) {
        let predicate = NSPredicate(format: "recordName IN %@", named)
        let removed: [Event] = fetch(predicate: predicate)
        Logging.log("Remove \(removed.count) events")
        delete(objects: removed)
    }

    internal func markFailure(on events: [String]) {
        let predicate = NSPredicate(format: "recordName IN %@", events)
        let failed: [Event] = fetch(predicate: predicate)
        failed.forEach({ $0.markSyncFailed() })
    }
    
    internal func load(events: [Cloud.Event]) {
        let deviceIds = Set(events.compactMap({ $0.device }))
        let devices = self.devices(with: Array(deviceIds))
        
        for event in events {
            guard let device = devices.first(where: { $0.recordName == event.device }) else {
                continue
            }
            
            let saved: Event = insertEntity()
            saved.device = device
            saved.recordName = event.recordName
            saved.name = event.name
            saved.time = event.time
            saved.values = event.values
        }
    }
    
    internal func countSessions(on date: Date, for app: Application) -> Int {
        let start = Calendar.current.startOfDay(for: date)
        guard let end = Calendar.current.date(byAdding: .day, value: 1, to: start) else {
            return 0
        }
        
        let appPredicate = NSPredicate(format: "device.application = %@", app)
        let startPredicate = NSPredicate(format: "time >= %@", start as NSDate)
        let endPredicate = NSPredicate(format: "time < %@", end as NSDate)
        let periodPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [startPredicate, endPredicate])
        let sessionStartPredicate = NSPredicate(format: "name = %@", String.sessionStart as NSString)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [appPredicate, sessionStartPredicate, periodPredicate])
        return count(instancesOf: Event.self, predicate: predicate)
    }

}
