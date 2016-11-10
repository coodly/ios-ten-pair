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
    fileprivate var background: GameButton!
    fileprivate lazy var box: AlertBox = {
        return AlertBox()
    }()
    var message: String!
    fileprivate lazy var dismissAction: SKAction = {
        return SKAction.run() {
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
        background.anchorPoint = CGPoint.zero
        background.color = TenPairTheme.currentTheme.backgroundColor!.withAlphaComponent(0.95)
        background.action = dismissAction
        addChild(background)
        
        box.size = CGSize(width: 300, height: 200)
        box.message = message
        addGameView(box)
    }
    
    override func positionContent() {
        super.positionContent()
        
        background.size = size
        box.position = CGPoint(x: (size.width - box.size.width) / 2, y: (size.height - box.size.height) / 2)
    }
    
    func addAction(_ iconName: String, closure: @escaping () -> ()) {
        let closureAction = SKAction.run(closure)
        let combinedAction = SKAction.sequence([closureAction, dismissAction])
        
        box.addAction(iconName, action: combinedAction)
    }
}

private class AlertBox: GameView {
    fileprivate var background: SKShapeNode!
    fileprivate var message: String!
    fileprivate var text: SKSpriteNode!
    fileprivate var buttons = [GameButton]()
    fileprivate var separator: SKShapeNode!
    
    fileprivate override func loadContent() {
        super.loadContent()
        
        background = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height), cornerRadius: 10)
        background.strokeColor = TenPairTheme.currentTheme.defaultNumberTileColor!
        background.fillColor = SKColor.white
        addChild(background)
        
        text = SKSpriteNode.multiLineLabel(message, font: "Copperplate-Bold", fontSize: 32, maxWidth: size.width - 20)
        text.color = TenPairTheme.currentTheme.defaultNumberTileColor!
        text.anchorPoint = CGPoint.zero
        addChild(text)
        
        for button in buttons {
            addGameView(button)
        }
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: size.width, y: 0))
        separator = SKShapeNode(path: path)
        separator.strokeColor = TenPairTheme.currentTheme.defaultNumberTileColor!
        addChild(separator)
    }
    
    fileprivate override func positionContent() {
        text.position = CGPoint(x: (size.width - text.size.width) / 2, y: size.height - text.size.height - 10)
        let buttonWidth = size.width / CGFloat(buttons.count)
        
        var buttonXOffset = CGFloat(0)
        for button in buttons {
            button.position = CGPoint(x: buttonXOffset, y: 0)
            button.size = CGSize(width: buttonWidth, height: 44)
            buttonXOffset += buttonWidth
        }
        
        separator.position = CGPoint(x: 0, y: 44)
        
        super.positionContent()
    }
    
    fileprivate func addAction(_ iconName: String, action: SKAction) {
        let button = GameButton.buttonWithImage(iconName, action: action)
        button.anchorPoint = CGPoint.zero
        button.image?.color = TenPairTheme.currentTheme.defaultNumberTileColor!
        button.image?.colorBlendFactor = 1
        buttons.append(button)
    }
}
