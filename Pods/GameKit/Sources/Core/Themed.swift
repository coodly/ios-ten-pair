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

public protocol Themed {
    static func appearance() -> Appearance
    
    func set(_ color: SKColor, for attribute: Appearance.Attribute)
}

public extension Themed where Self: SKNode {
    static func appearance() -> Appearance {
        let key = appearanceKey()
        return Appearance.appearance(for: key)!
    }
    
    internal func applyTheme() {
        themeMe()
    }

    internal static func appearanceKey() -> String {
        var components = [String]()
        components.append(String(describing: self))
        var sup: AnyClass? = class_getSuperclass(self)
        while true {
            guard let added = sup else {
                break
            }
            
            components.append(String(describing: added))
            sup = class_getSuperclass(sup)
        }
        return components.joined(separator: ".")
    }
}

fileprivate extension SKNode {
    func themeMe() {
        guard let themable = self as? Themed else {
            themeChildren()
            return
        }
        
        print(appearanceKey())
        let attributes = Appearance.attributes(for: appearanceKey())
        for (key, value) in attributes {
            switch value {
            case is SKColor:
                themable.set(value as! SKColor, for: key)
            default:
                fatalError("Unhandled attribute")
            }
        }
        
        themeChildren()
    }
    
    private func themeChildren() {
        for child in children {
            child.themeMe()
        }
    }
    
    private func appearanceKey() -> String {
        var components = [String]()
        components.append(String(describing: type(of: self)))
        var sup: AnyClass? = self.superclass
        while true {
            guard let added = sup else {
                break
            }
            
            components.append(String(describing: added))
            sup = class_getSuperclass(sup)
        }
        return components.joined(separator: ".")
    }
}
