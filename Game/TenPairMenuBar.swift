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
import GameKit

class TenPairMenuBar: GameView {
    var menuButton: GameButton?
    var reloadButton: GameButton?
    var fieldStatus: TenPairFieldStatus?
    var background: GameButton?
    
    override func loadContent() {
        name = "InGameMenuBar"
        
        color = TenPairTheme.currentTheme.backgroundColor!.withAlphaComponent(0.9)

        let background = GameButton()
        self.background = background
        background.name = "Menu background"
        background.anchorPoint = CGPoint.zero
        background.size = size
        background.action = SKAction.wait(forDuration: 0)
        addChild(background)

        let menuButton = GameButton(imageNamed: "menu")
        self.menuButton = menuButton
        menuButton.anchorPoint = CGPoint(x: 0, y: 0)
        menuButton.size = CGSize(width: size.height, height: size.height)
        menuButton.position = CGPoint(x: 10, y: 0)
        menuButton.color = TenPairTheme.currentTheme.tintColor!
        menuButton.colorBlendFactor = 1
        menuButton.name = "Menu button"
        addChild(menuButton)

        let reloadButton = GameButton(imageNamed: "reload")
        self.reloadButton = reloadButton
        reloadButton.touchDisables = true
        reloadButton.anchorPoint = CGPoint(x: 0, y: 0)
        reloadButton.size = CGSize(width: size.height, height: size.height)
        reloadButton.position = CGPoint(x: size.width - reloadButton.size.width - 10, y: 0)
        reloadButton.color = TenPairTheme.currentTheme.tintColor!
        reloadButton.colorBlendFactor = 1
        reloadButton.name = "Reload button"
        addChild(reloadButton)
        
        let fieldStatus = TenPairFieldStatus()
        self.fieldStatus = fieldStatus
        fieldStatus.anchorPoint = CGPoint.zero
        fieldStatus.size = CGSize(width: 200, height: size.height)
        fieldStatus.position = CGPoint(x: (size.width - fieldStatus.size.width) / 2, y: 0)
        addGameView(fieldStatus)
    }
    
    override func positionContent() {
        background!.size = size
        menuButton!.position = CGPoint(x: 10, y: 0)
        reloadButton!.position = CGPoint(x: size.width - reloadButton!.size.width - 10, y: 0)
        fieldStatus!.position = CGPoint(x: (size.width - fieldStatus!.size.width) / 2, y: 0)
        
        super.positionContent()
    }
}
