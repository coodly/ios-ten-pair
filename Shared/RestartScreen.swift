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

import SpriteKitUI
import SpriteKit

public enum StartField {
    case regular
    case random(Int)
}

class RestartScreen: MenuScreen {
    override func load() {
        let regular = button(named: NSLocalizedString("restart.screen.option.regular", comment: ""))
        regular.action = SKAction.run {
            [weak self] in
            
            self?.restart(with: .regular)
        }
        append(regular)
        
        appendRandomOption(20)
        appendRandomOption(50)
        appendRandomOption(100)
        appendRandomOption(250)

        let backButton = button(named: "Back")
        backButton.action = SKAction.run {
            [weak self] in
            
            guard let s = self else {
                return
            }
            
            s.dismiss(s)
        }
        append(backButton)
    }
    
    private func appendRandomOption(_ lines: Int) {
        let title = String(format: NSLocalizedString("restart.screen.option.x.lines", comment: ""), NSNumber(value: lines))
        let randomButton = button(named: title)
        randomButton.action = SKAction.run {
            [weak self] in
            
            self?.restart(with: .random(lines))
        }
        append(randomButton)
    }
    
    private func restart(with option: StartField) {
        restartHandler?(option)
    }
}
