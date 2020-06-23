/*
* Copyright 2020 Coodly LLC
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
import UIKit

private let ThemeSettingKey = "ThemeSettingKey"

internal class AppTheme {
    internal static let classic = ThemeDefinition(name: "classic",
                                                  main: UIColor(red: 0.353, green: 0.784, blue: 0.980, alpha: 1),
                                                  selected: UIColor(red: 0, green: 0.400, blue: 1.000, alpha: 1),
                                                  success: UIColor(red: 0.239, green: 0.792, blue: 0.416, alpha: 1))
    
    internal static let pink = ThemeDefinition(name: "pink",
                                               main: UIColor(red: 1, green: 105.0 / 255.0, blue: 180.0 / 255.0, alpha: 1),
                                               selected: UIColor(red: 60.0 / 255.0, green: 145.0 / 255.0, blue: 230.0 / 255.0, alpha: 1),
                                               success: UIColor(red: 27.0 / 255.0, green: 153.0 / 255.0, blue: 130.0 / 255.0, alpha: 1))
    
    internal static let dark = ThemeDefinition(name: "dark",
                                               main: UIColor.color(hexString: "#243458"),
                                               selected: UIColor(red: 0, green: 0.400, blue: 1.000, alpha: 1),
                                               success: UIColor(red: 0.239, green: 0.792, blue: 0.416, alpha: 1))
    
    private static let all: [ThemeDefinition] = [classic, pink, dark]
    
    internal static let shared = AppTheme()
    
    internal var active: ThemeDefinition {
        activeTheme
    }
    
    private init() {}
    
    internal func load() {
        apply(theme: activeTheme)
    }
    
    private var activeTheme: ThemeDefinition {
        let name = UserDefaults.standard.string(forKey: ThemeSettingKey) ?? "classic"
        if let existing = AppTheme.all.filter({ $0.name == name }).first {
            return existing
        }
        
        return AppTheme.classic
    }
    
    private func apply(theme: ThemeDefinition) {
        UINavigationBar.appearance().tintColor = theme.main
        TileDefaultBackground.appearance().backgroundColor = theme.main
        TileNoNumberBackground.appearance().backgroundColor = theme.empty
        TileSelectedBackground.appearance().backgroundColor = theme.selected
        TileSuccessBackground.appearance().backgroundColor = theme.success
        TileFailureBackground.appearance().backgroundColor = theme.failure
    }
    
    internal func switchToNext() -> ThemeDefinition {
        let current = activeTheme
        guard let index = AppTheme.all.firstIndex(of: current) else {
            return active
        }
        
        let next = index.advanced(by: 1)
        let returned: ThemeDefinition
        if AppTheme.all.endIndex <= next {
            returned = AppTheme.all.first!
        } else {
            returned = AppTheme.all[next]
        }
        
        apply(theme: returned)
        UserDefaults.standard.set(returned.name, forKey: ThemeSettingKey)
        for window in UIApplication.shared.windows {
            for sub in window.subviews {
                sub.removeFromSuperview()
                window.addSubview(sub)
            }
        }
        return returned
    }
}

internal struct ThemeDefinition: Equatable {
    let name: String
    let main: UIColor
    let selected: UIColor
    let success: UIColor
    let failure = UIColor(red: 1.000, green: 0.173, blue: 0.333, alpha: 1)
    let empty = UIColor(white: 0.900, alpha: 1.000)
    
    internal var localizedName: String {
        let key = "theme.name.\(name)"
        return NSLocalizedString(key, comment: "")
    }
}

internal class TileDefaultBackground: UIView {
    
}

internal class TileNoNumberBackground: UIView {
    
}

internal class TileSuccessBackground: UIView {
    
}

internal class TileFailureBackground: UIView {
    
}

internal class TileSelectedBackground: UIView {
    
}
