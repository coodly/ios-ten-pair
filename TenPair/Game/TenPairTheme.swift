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

import Foundation
import SpriteKit

class TenPairTheme {
    class var currentTheme :TenPairTheme {
        struct Singleton {
            static let instance = TenPairDefaultTheme()
        }
        
        return Singleton.instance
    }
    
    var tintColor: SKColor?
    var backgroundColor: SKColor?
    var defaultNumberTileColor: SKColor?
    var tileNumberColor: SKColor?
    var selectedTileColor: SKColor?
    var errorTileColor: SKColor?
    var successTileColor: SKColor?
    var consumedTileColor: SKColor?
    var menuTitleColor: SKColor?
    var menuOptionBackgroundColor: SKColor?
    
    init(tintColor: SKColor, backgroundColor: SKColor, defaultNumberTileColor: SKColor, tileNumberColor: SKColor, selectedTileColor: SKColor, errorTileColor: SKColor, successTileColor: SKColor, consumedTileColor: SKColor, menuTitleColor: SKColor, menuOptionBackgroundColor: SKColor) {
        self.tintColor = tintColor
        self.backgroundColor = backgroundColor
        self.defaultNumberTileColor = defaultNumberTileColor
        self.tileNumberColor = tileNumberColor
        self.selectedTileColor = selectedTileColor
        self.errorTileColor = errorTileColor
        self.successTileColor = successTileColor
        self.consumedTileColor = consumedTileColor
        self.menuTitleColor = menuTitleColor
        self.menuOptionBackgroundColor = menuOptionBackgroundColor
    }
}