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

import Foundation
import SpriteKit
import SpriteKitUI

class TenPair: Game {
    private var play: PlayScreen?
    override func start() {
        setAppearance()
        play = PlayScreen()
        play?.name = "Play screen"
        present(screen: play!)
    }
    
    private func setAppearance() {
        let lightBlue = SKColor(red: 0.353, green: 0.784, blue: 0.980, alpha: 1)
        View.appearance().set(color: SKColor.white, for: .background)
        View.appearance().set(color: lightBlue, for: .foreground)

        TopMenuBar.appearance().set(color: SKColor.white.withAlphaComponent(0.95), for: .background)

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
        
        HintsButtonTray.appearance().set(color: lightBlue, for: .background)
        HintsButtonTray.appearance().set(color: .white, for: .foreground)
        
        HintButton.appearance().set(color: .white, for: .foreground)
        HintButton.appearance().set(color: .clear, for: .background)
        
        WinScreen.appearance().set(color: .clear, for: .background)
    }
}

extension Appearance.Attribute {
    static let tile = "TenPairTile"
    static let tileNumber = "TenPairTileNumber"
    static let selected = "TenPairSelected"
    static let success = "TenPairSuccess"
    static let failure = "TenPairFailure"
    static let numberFieldBackground = "TenPairNumberFieldBackground"
}
