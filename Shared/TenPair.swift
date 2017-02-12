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
import GameKit
import SpriteKit

class TenPair: Game {
    private var play: PlayScreen?
    override func start() {
        setAppearance()
        play = PlayScreen()
        present(screen: play!)
    }
    
    private func setAppearance() {
        View.appearance().set(SKColor.white, for: .background)
        View.appearance().set(SKColor(red: 0.353, green: 0.784, blue: 0.980, alpha: 1), for: .foreground)
        StatusBar.appearance().set(.clear, for: .background)
        NumbersField.appearance().set(SKColor(red: 0, green: 0.400, blue: 1.000, alpha: 1), for: .selected)
        NumbersField.appearance().set(SKColor(red: 0.239, green: 0.792, blue: 0.416, alpha: 1), for: .success)
        NumbersField.appearance().set(SKColor(red: 1.000, green: 0.173, blue: 0.333, alpha: 1), for: .failure)
        NumbersField.appearance().set(SKColor(white: 0.900, alpha: 1.000), for: .numberFieldBackground)
        Button.appearance().set(.white, for: .title)
        GameKit.MenuScreen.appearance().set(SKColor.white.withAlphaComponent(0.95), for: .background)
        TopMenuBar.appearance().set(SKColor.white.withAlphaComponent(0.95), for: .background)
    }
}

extension Appearance.Attribute {
    static let selected = "TenPairSelected"
    static let success = "TenPairSuccess"
    static let failure = "TenPairFailure"
    static let numberFieldBackground = "TenPairNumberFieldBackground"
}
