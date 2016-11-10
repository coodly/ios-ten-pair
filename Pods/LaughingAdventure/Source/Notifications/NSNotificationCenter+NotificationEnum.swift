/*
 * Copyright 2015 Coodly LLC
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

public protocol CoodlyNotification {
    
}

public extension NotificationCenter {
    func postNotification(_ notification: CoodlyNotification, object: AnyObject? = nil) {
        let name = String(reflecting: notification)
        Logging.log("Post notification named \(name)")
        post(name: Notification.Name(rawValue: name), object: object)
    }
    
    func addObserver(_ observer: AnyObject, selector aSelector: Selector, notification: CoodlyNotification) {
        addObserver(observer, selector: aSelector, name: NSNotification.Name(rawValue: String(reflecting: notification)), object: nil)
    }
}
