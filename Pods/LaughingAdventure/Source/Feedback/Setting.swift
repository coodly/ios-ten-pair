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

@objc(Setting)
internal class Setting: NSManagedObject {
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    var dateValue: Date? {
        set {
            if let date = newValue {
                value = Setting.formatter.string(from: date)
            } else {
                value = nil
            }
        }
        get {
            if let v = value, let date = Setting.formatter.date(from: v) {
                return date
            }
            
            return nil
        }
    }
}

extension Setting {
    @NSManaged var key: NSNumber
    @NSManaged var value: String?
}
