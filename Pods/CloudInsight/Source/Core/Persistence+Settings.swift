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
import CoreDataPersistence

internal protocol Timestamped {
    static var lastKnownKey: String { get }
    
    var modifiedAt: Date? { get }
}

extension NSManagedObjectContext {
    internal func markLastKnow<T: Timestamped>(time: Date, for type: T.Type) {
        mark(date: time, for: T.lastKnownKey)
    }
    
    internal func lastKnownTime<T: Timestamped>(for type: T.Type) -> Date {
        date(for: T.lastKnownKey, fallback: Date.distantPast)
    }
}

extension NSManagedObjectContext {
    private func date(for rawKey: String, fallback: Date) -> Date {
        return setting(for: rawKey)?.dateValue ?? fallback
    }
    
    private func mark(date: Date, for rawKey: String) {
        let saved = setting(for: rawKey) ?? insertEntity()
        saved.key = rawKey
        saved.dateValue = date
    }
}

extension NSManagedObjectContext {
    private func setting(for rawKey: String) -> Setting? {
        return fetchEntity(where: "key", hasValue: rawKey)
    }
    
    private func mark(value: String, for rawKey: String) {
        let saved = setting(for: rawKey) ?? insertEntity()
        saved.key = rawKey
        saved.value = value
    }
}
