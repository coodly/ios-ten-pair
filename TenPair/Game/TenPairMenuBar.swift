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
        
        color = TenPairTheme.currentTheme.backgroundColor!.colorWithAlphaComponent(0.9)

        let background = GameButton()
        self.background = background
        background.anchorPoint = CGPointZero
        background.size = size
        background.action = SKAction.waitForDuration(0)
        addChild(background)

        let menuButton = GameButton(imageNamed: "menu")
        self.menuButton = menuButton
        menuButton.anchorPoint = CGPointMake(0, 0)
        menuButton.size = CGSizeMake(size.height, size.height)
        menuButton.position = CGPointMake(10, 0)
        menuButton.color = TenPairTheme.currentTheme.tintColor!
        menuButton.colorBlendFactor = 1
        menuButton.zPosition = 1
        addChild(menuButton)

        let reloadButton = GameButton(imageNamed: "reload")
        self.reloadButton = reloadButton
        reloadButton.touchDisables = true
        reloadButton.anchorPoint = CGPointMake(0, 0)
        reloadButton.size = CGSizeMake(size.height, size.height)
        reloadButton.position = CGPointMake(size.width - reloadButton.size.width - 10, 0)
        reloadButton.color = TenPairTheme.currentTheme.tintColor!
        reloadButton.colorBlendFactor = 1
        reloadButton.zPosition = 1
        addChild(reloadButton)
        
        let fieldStatus = TenPairFieldStatus()
        self.fieldStatus = fieldStatus
        fieldStatus.anchorPoint = CGPointZero
        fieldStatus.size = CGSizeMake(200, size.height)
        fieldStatus.position = CGPointMake((size.width - fieldStatus.size.width) / 2, 0)
        addGameView(fieldStatus)
    }
    
    override func positionContent() {
        background!.size = size
        menuButton!.position = CGPointMake(10, 0)
        reloadButton!.position = CGPointMake(size.width - reloadButton!.size.width - 10, 0)
        fieldStatus!.position = CGPointMake((size.width - fieldStatus!.size.width) / 2, 0)
        
        super.positionContent()
    }
}