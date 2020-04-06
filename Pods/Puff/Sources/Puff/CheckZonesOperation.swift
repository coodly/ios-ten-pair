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
import CloudKit
#if canImport(PuffLogger)
import PuffLogger
#endif

public class CheckZonesOperation: ConcurrentOperation {
    private let zones: [CKRecordZone]
    private let database: CKDatabase
    public init(zones: [CKRecordZone], database: CKDatabase) {
        self.zones = zones
        self.database = database
    }
    
    public override func main() {
        Logging.log("Fetch all record zones")
        database.fetchAllRecordZones() {
            zones, error in
            
            if let error = error {
                Logging.log("Fetch zones error: \(error)")
                self.finish()
                return
            }
            
            let existing = zones ?? []
            Logging.log("Existing zones \(existing)")
            let existingIds = existing.map({ $0.zoneID })
            let create = self.zones.filter({ !existingIds.contains($0.zoneID ) })
            self.create(zones: create)
        }
    }
    
    private func create(zones: [CKRecordZone]) {
        Logging.log("Create zones \(zones)")
        guard zones.count > 0 else {
            self.finish()
            return
        }

        let op = CKModifyRecordZonesOperation(recordZonesToSave: zones, recordZoneIDsToDelete: nil)
        op.modifyRecordZonesCompletionBlock = {
            modified, deleted, error in
            
            self.finish(error)
            
            if let error = error {
                Logging.log("Create zones error \(error)")
            } else {
                Logging.log("Saved: \(modified ?? []), deleted: \(deleted ?? [])")
            }
        }
        database.add(op)
    }
}
