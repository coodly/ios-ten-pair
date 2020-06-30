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
import SpriteKitUI

private let ThemeSettingKey = "ThemeSettingKey"

class Theme {
    private static var classic: Theme = {
        let theme = Theme("classic") {
            let lightBlue = SKColor(red: 0.353, green: 0.784, blue: 0.980, alpha: 1)
            View.appearance().set(color: SKColor.white, for: .background)
            View.appearance().set(color: lightBlue, for: .foreground)
            
            TopMenuBackground.appearance().set(color: SKColor.white.withAlphaComponent(0.95), for: .background)
            TopMenuBar.appearance().set(color: SKColor.clear, for: .background)
            
            Button.appearance().set(color: .clear, for: .background)
            
            MenuButton.appearance().set(color: lightBlue, for: .background)
            MenuButton.appearance().set(color: SKColor.white, for: .foreground)
            MenuButton.appearance().set(value: "Copperplate-Bold", for: .font)
            
            SpriteKitUI.MenuScreen.appearance().set(color: SKColor.white.withAlphaComponent(0.95), for: .background)
            
            StatusBar.appearance().set(color: .clear, for: .background)
            StatusBar.appearance().set(value: "Copperplate-Bold", for: .font)
            
            NumbersField.appearance().set(color: lightBlue, for: .tile)
            NumbersField.appearance().set(color: .white, for: .tileNumber)
            NumbersField.appearance().set(color: SKColor(red: 0, green: 0.400, blue: 1.000, alpha: 1), for: .selected)
            NumbersField.appearance().set(color: SKColor(red: 0.239, green: 0.792, blue: 0.416, alpha: 1), for: .success)
            NumbersField.appearance().set(color: SKColor(red: 1.000, green: 0.173, blue: 0.333, alpha: 1), for: .failure)
            NumbersField.appearance().set(color: SKColor(white: 0.900, alpha: 1.000), for: .numberFieldBackground)
            
            LoadingScreen.appearance().set(color: SKColor.white.withAlphaComponent(0.8), for: .background)
            
            FieldStatusView.appearance().set(color: .clear, for: .background)
            
            ButtonTray.appearance().set(color: lightBlue, for: .background)
            ButtonTray.appearance().set(color: .white, for: .foreground)
            
            TrayButton.appearance().set(color: .white, for: .foreground)
            TrayButton.appearance().set(color: .clear, for: .background)
            
            WinScreen.appearance().set(color: .clear, for: .background)
        }
        return theme
    }()
    
    private static var pink: Theme = {
        let theme = Theme("pink") {
            let pinkColor = SKColor(red: 1, green: 105.0 / 255.0, blue: 180.0 / 255.0, alpha: 1)
            View.appearance().set(color: SKColor.white, for: .background)
            View.appearance().set(color: pinkColor, for: .foreground)
            
            TopMenuBackground.appearance().set(color: SKColor.white.withAlphaComponent(0.95), for: .background)
            TopMenuBar.appearance().set(color: SKColor.clear, for: .background)

            Button.appearance().set(color: .clear, for: .background)
            
            MenuButton.appearance().set(color: pinkColor, for: .background)
            MenuButton.appearance().set(color: SKColor.white, for: .foreground)
            MenuButton.appearance().set(value: "Copperplate-Bold", for: .font)
            
            SpriteKitUI.MenuScreen.appearance().set(color: SKColor.white.withAlphaComponent(0.95), for: .background)
            
            StatusBar.appearance().set(color: .clear, for: .background)
            StatusBar.appearance().set(value: "Copperplate-Bold", for: .font)
            
            NumbersField.appearance().set(color: pinkColor, for: .tile)
            NumbersField.appearance().set(color: .white, for: .tileNumber)
            NumbersField.appearance().set(color: SKColor(red: 60.0 / 255.0, green: 145.0 / 255.0, blue: 230.0 / 255.0, alpha: 1), for: .selected)
            NumbersField.appearance().set(color: SKColor(red: 27.0 / 255.0, green: 153.0 / 255.0, blue: 130.0 / 255.0, alpha: 1), for: .success)
            NumbersField.appearance().set(color: SKColor(red: 1.000, green: 0.173, blue: 0.333, alpha: 1), for: .failure)
            NumbersField.appearance().set(color: SKColor(white: 0.900, alpha: 1.000), for: .numberFieldBackground)
            
            LoadingScreen.appearance().set(color: SKColor.white.withAlphaComponent(0.8), for: .background)
            
            FieldStatusView.appearance().set(color: .clear, for: .background)
            
            ButtonTray.appearance().set(color: pinkColor, for: .background)
            ButtonTray.appearance().set(color: .white, for: .foreground)
            
            TrayButton.appearance().set(color: .white, for: .foreground)
            TrayButton.appearance().set(color: .clear, for: .background)
            
            WinScreen.appearance().set(color: .clear, for: .background)
        }
        
        return theme
    }()
    
    private static var dark: Theme = {
        let theme = Theme("dark") {
            let background = SKColor.color(hexString: "#121212")
            let tiles = SKColor.color(hexString: "#243458")
            let text = SKColor.color(hexString: "#D4D4D4")

            let foreground = tiles
            View.appearance().set(color: background, for: .background)
            View.appearance().set(color: foreground, for: .foreground)
            
            TopMenuBackground.appearance().set(color: background.withAlphaComponent(0.95), for: .background)
            TopMenuBar.appearance().set(color: SKColor.clear, for: .background)
            TopMenuBar.appearance().set(color: text, for: .foreground)

            Button.appearance().set(color: .clear, for: .background)
            Button.appearance().set(color: text, for: .foreground)
            
            MenuButton.appearance().set(color: foreground, for: .background)
            MenuButton.appearance().set(color: SKColor.white, for: .foreground)
            MenuButton.appearance().set(value: "Copperplate-Bold", for: .font)
            
            SpriteKitUI.MenuScreen.appearance().set(color: background.withAlphaComponent(0.95), for: .background)
            
            StatusBar.appearance().set(color: .clear, for: .background)
            StatusBar.appearance().set(value: "Copperplate-Bold", for: .font)
            
            NumbersField.appearance().set(color: tiles, for: .tile)
            NumbersField.appearance().set(color: text, for: .tileNumber)
            NumbersField.appearance().set(color: SKColor(red: 60.0 / 255.0, green: 145.0 / 255.0, blue: 230.0 / 255.0, alpha: 1), for: .selected)
            NumbersField.appearance().set(color: SKColor(red: 27.0 / 255.0, green: 153.0 / 255.0, blue: 130.0 / 255.0, alpha: 1), for: .success)
            NumbersField.appearance().set(color: SKColor(red: 1.000, green: 0.173, blue: 0.333, alpha: 1), for: .failure)
            NumbersField.appearance().set(color: SKColor(white: 0.500, alpha: 1.000), for: .numberFieldBackground)
            
            LoadingScreen.appearance().set(color: background.withAlphaComponent(0.8), for: .background)
            LoadingScreen.appearance().set(color: text, for: .foreground)
            
            FieldStatusView.appearance().set(color: .clear, for: .background)
            FieldStatusView.appearance().set(color: text, for: .foreground)
            
            ButtonTray.appearance().set(color: foreground, for: .background)
            ButtonTray.appearance().set(color: .white, for: .foreground)
            
            TrayButton.appearance().set(color: text, for: .foreground)
            TrayButton.appearance().set(color: .clear, for: .background)
            
            WinScreen.appearance().set(color: .clear, for: .background)
        }
        
        return theme
    }()
    
    private static var all = [
        classic,
        pink,
        dark
    ]
    
    var localizedName: String {
        let key = "theme.name.\(name)"
        return NSLocalizedString(key, comment: "")
    }
    private let name: String
    private let initialize: (() -> ())
    private init(_ name: String, initialize: @escaping (() -> ())) {
        self.name = name
        self.initialize = initialize
    }
    
    func load() {
        initialize()
    }
    
    static func current() -> Theme {
        let name = UserDefaults.standard.string(forKey: ThemeSettingKey) ?? "classic"
        if let existing = all.filter({ $0.name == name }).first {
            return existing
        }
        
        return classic
    }
    
    static func next() -> Theme {
        let active = current()
        guard let index = all.firstIndex(where: { $0.name == active.name }) else {
            return active
        }
        
        let next = index.advanced(by: 1)
        let returned: Theme
        if all.endIndex <= next {
            returned = all.first!
        } else {
            returned = all[next]
        }
        
        UserDefaults.standard.set(returned.name, forKey: ThemeSettingKey)
        return returned
    }
}
