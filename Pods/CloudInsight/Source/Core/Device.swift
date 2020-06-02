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
import CoreData

internal class Device: NSManagedObject, Synced {
    @NSManaged var model: String?
    @NSManaged var osVersion: String?
    @NSManaged var createdOn: Date?
    
    @NSManaged var recordName: String?
    @NSManaged var recordData: Data?
    
    @NSManaged var syncStatus: SyncStatus?
    @NSManaged var application: Application?
    @NSManaged var user: User?    
    @NSManaged var events: Set<Event>?
}

extension Device {
    internal func refresh(model: String, version: String) -> Bool {
        Logging.log("Model: \(model), version: \(version)")
        let changed = self.model != model || self.osVersion != version
        
        self.model = model
        self.osVersion = version
        
        return changed
    }
}
