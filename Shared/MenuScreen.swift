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
    var restartAction: SKAction?
    
    override var itemSize: CGSize {
        let buttonWidth = min(size.width - 80, 400)
        let buttonHeight = round(buttonWidth / 6)
        return CGSize(width: buttonWidth, height: buttonHeight)
    }
    
    override func load() {
        if AppConfig.current.statusBar {
            let statusBar = StatusBar()
            add(toTop: statusBar, height: 20)
        }
        
        let resume = button(named: NSLocalizedString("menu.option.resume", comment: ""))
        append(resume)
        resume.action = SKAction.run {
            [weak self] in
            
            guard let me = self else {
                return
            }
            
            me.dismiss(me)
        }
        
        let restartButton = button(named: NSLocalizedString("menu.option.restart", comment: ""))
        restartButton.action = restartAction
        append(restartButton)
        
        append(button(named: NSLocalizedString("menu.option.full.version.purchased", comment: "")))
        append(button(named: NSLocalizedString("menu.option.send.message", comment: "")))
    }
    
    override func positionChildren() {
        super.positionChildren()
        
        for b in allOptions {
            b.titleFontSize = itemSize.height / 2
        }
    }
    
    private func button(named title: String) -> MenuButton {
        let button = MenuButton()
        button.name = title
        button.set(title: title)
        return button
    }
}
