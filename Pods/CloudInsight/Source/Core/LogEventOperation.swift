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
import KeychainAccess

private typealias Dependencies = PersistenceConsumer & KeychainConsumer

internal class LogEventOperation: ConcurrentOperation, Dependencies {
    var persistence: CorePersistence!
    var keychain: Keychain!
    
    private let time: Date
    private let eventName: String
    private let values: [String: String]
    internal init(time: Date = Date(), name: String, values: [String: String]) {
        self.time = time
        self.eventName = name
        self.values = values
    }
    
    override func main() {
        persistence.write() {
            context in
            
            let event: Event = context.insertEntity()
            
            event.recordName = UUID().uuidString
            event.deviceIdentifier = keychain.deviceId
            event.name = eventName
            event.time = time
            if values.count > 0, let data = try? JSONSerialization.data(withJSONObject: values, options: []), let string = String(data: data, encoding: .utf8) {
                event.values = string
            }
            
            event.markSyncNeed()
        }
        
        finish()
    }
}
