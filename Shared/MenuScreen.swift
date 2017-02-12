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

import GameKit
import SpriteKit

class MenuScreen: GameKit.MenuScreen {
    override var itemSize: CGSize {
        return CGSize(width: 200, height: 44)
    }
    
    override func load() {
        let statusBar = StatusBar()
        add(toTop: statusBar, height: 20)
        
        let resume = button(named: "Resume game")
        append(resume)
        resume.action = SKAction.run {
            [weak self] in
            
            guard let me = self else {
                return
            }
            
            me.dismiss(me)
        }
        append(button(named: "Restart game"))
        append(button(named: "Full version"))
        append(button(named: "Message to developer"))
    }
    
    private func button(named title: String) -> MenuButton {
        let button = MenuButton()
        button.name = title
        button.set(title: title)
        return button
    }
}
