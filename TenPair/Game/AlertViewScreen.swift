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
import SWLogger

class AlertViewScreen: GameScreen {
    private var background: GameButton!
    private lazy var box: AlertBox = {
        return AlertBox()
    }()
    var message: String!
    private lazy var dismissAction: SKAction = {
        return SKAction.runBlock() {
            [unowned self] in
            
            self.dismiss()
        }
    }()
    
    deinit {
        Log.debug("")
    }
    
    override func loadContent() {
        super.loadContent()
        
        name = "Alert view screen"
        
        background = GameButton()
        background.anchorPoint = CGPointZero
        background.color = TenPairTheme.currentTheme.backgroundColor!.colorWithAlphaComponent(0.95)
        background.action = dismissAction
        addChild(background)
        
        box.size = CGSizeMake(300, 200)
        box.message = message
        addGameView(box)
    }
    
    override func positionContent() {
        super.positionContent()
        
        background.size = size
        box.position = CGPointMake((size.width - box.size.width) / 2, (size.height - box.size.height) / 2)
    }
    
    func addAction(iconName: String, closure: () -> ()) {
        let closureAction = SKAction.runBlock(closure)
        let combinedAction = SKAction.sequence([closureAction, dismissAction])
        
        box.addAction(iconName, action: combinedAction)
    }
}

private class AlertBox: GameView {
    private var background: SKShapeNode!
    private var message: String!
    private var text: SKSpriteNode!
    private var buttons = [GameButton]()
    private var separator: SKShapeNode!
    
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
        
        for button in buttons {
            addGameView(button)
        }
        
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, 0, 0)
        CGPathAddLineToPoint(path, nil, size.width, 0)
        separator = SKShapeNode(path: path)
        separator.strokeColor = TenPairTheme.currentTheme.defaultNumberTileColor!
        addChild(separator)
    }
    
    private override func positionContent() {
        text.position = CGPointMake((size.width - text.size.width) / 2, size.height - text.size.height - 10)
        let buttonWidth = size.width / CGFloat(buttons.count)
        
        var buttonXOffset = CGFloat(0)
        for button in buttons {
            button.position = CGPointMake(buttonXOffset, 0)
            button.size = CGSizeMake(buttonWidth, 44)
            buttonXOffset += buttonWidth
        }
        
        separator.position = CGPointMake(0, 44)
        
        super.positionContent()
    }
    
    private func addAction(iconName: String, action: SKAction) {
        let button = GameButton.buttonWithImage(iconName, action: action)
        button.anchorPoint = CGPointZero
        button.image?.color = TenPairTheme.currentTheme.defaultNumberTileColor!
        button.image?.colorBlendFactor = 1
        buttons.append(button)
    }
}
