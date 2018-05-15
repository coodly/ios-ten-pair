/*
 * Copyright 2017 Coodly LLC
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

import SpriteKit

public extension Appearance.Attribute {
    static let foreground = "foreground" + UUID().uuidString
    static let background = "background" + UUID().uuidString
}

public class Appearance {
    public typealias Attribute = String
    
    private static var register: [String: Appearance] = [:]
    private var values: [String: Any] = [:]
    
    public func set(color: SKColor, for attribute: Appearance.Attribute) {
        values[attribute] = color
    }
    
    public func set(value: String, for attribute: Appearance.Attribute) {
        values[attribute] = value
    }
    
    internal static func appearance(for key: String, create: Bool = true) -> Appearance? {
        if let existing = Appearance.register[key] {
            return existing
        }
        
        guard create else {
            return nil
        }
        
        let created = Appearance()
        register[key] = created
        return created
    }
    
    internal static func attributes(for key: String) -> [String: Any] {
        let atoms = key.components(separatedBy: ".").reversed()
        var attributes: [String: Any] = [:]
        var key = ""
        for atom in atoms {
            if key.count > 0 {
                key = "." + key
            }
            
            key = atom + key
            
            guard let appearance = Appearance.appearance(for: key, create: false) else {
                continue
            }
            
            for (name, value) in appearance.values {
                attributes[name] = value
            }
        }
        return attributes
    }
}
