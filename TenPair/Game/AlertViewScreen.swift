/*
 * Copyright 2016 Coodly LLC
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

class AlertViewScreen: GameScreen {
    private var background: GameButton!
    private var box: AlertBox!
    var message: String!
    
    override func loadContent() {
        super.loadContent()
        
        name = "Alert view screen"
        
        background = GameButton()
        background.anchorPoint = CGPointZero
        background.color = TenPairTheme.currentTheme.backgroundColor!.colorWithAlphaComponent(0.95)
        background.action = SKAction.runBlock() {
            self.game?.dismissScreen(self)
        }
        addChild(background)
        
        box = AlertBox()
        box.size = CGSizeMake(300, 200)
        box.message = message
        addGameView(box)
    }
    
    override func positionContent() {
        super.positionContent()
        
        background.size = size
        box.position = CGPointMake((size.width - box.size.width) / 2, (size.height - box.size.height) / 2)
    }
}

private class AlertBox: GameView {
    private var background: SKShapeNode!
    private var message: String!
    private var text: SKSpriteNode!
    
    private override func loadContent() {
        super.loadContent()
        
        background = SKShapeNode(rect: CGRectMake(0, 0, size.width, size.height), cornerRadius: 10)
        background.strokeColor = TenPairTheme.currentTheme.defaultNumberTileColor!
        background.fillColor = UIColor.whiteColor()
        addChild(background)
        
        text = SKSpriteNode.multiLineLabel(message, font: "Copperplate-Bold", fontSize: 32, maxWidth: size.width - 20)
        text.color = TenPairTheme.currentTheme.defaultNumberTileColor!
        text.anchorPoint = CGPointZero
        addChild(text)
    }
    
    private override func positionContent() {
        super.positionContent()
        
        text.position = CGPointMake((size.width - text.size.width) / 2, size.height - text.size.height - 10)
    }
}