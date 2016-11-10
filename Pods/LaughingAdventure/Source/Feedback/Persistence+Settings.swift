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

private enum SettingKey: Int {
    case conversationsUpdateTime = 1
}

internal extension NSManagedObjectContext {
    func lastKnownConversationsTime() -> Date {
        return date(for: .conversationsUpdateTime, fallback: .distantPast)
    }
    
    func set(lastKnowConversationTime time: Date) {
        Logging.log("Last known conversation time: \(time)")
        set(date: time, for: .conversationsUpdateTime)
    }
    
    private func set(date: Date, for key: SettingKey) {
        let saved: Setting = setting(for: key) ?? insertEntity()
        
        saved.key = NSNumber(value: key.rawValue)
        saved.dateValue = date
    }
    
    private func date(for key: SettingKey, fallback: Date) -> Date {
        if let s = setting(for: key), let value = s.dateValue {
            return value
        }
        
        return fallback
    }
    
    private func setting(for key: SettingKey) -> Setting? {
        return fetchEntity(where: "key", hasValue: NSNumber(value: key.rawValue))
    }
}
