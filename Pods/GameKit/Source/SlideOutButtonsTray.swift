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
import SpriteKit

public class SlideOutButtonsTray: GameView {
    public var openButton: GameButton! {
        didSet {
            openButton.action = SKAction.runBlock() {
                self.toggleOpenState()
            }
        }
    }
    
    private var buttons = [GameButton]()
    private var opened = false
    private var closeX: CGFloat = 0
    
    public override func positionContent() {
        super.positionContent()
        
        
        let positioned = buttons + [openButton]
        let spacing = (size.height - openButton.size.height) / 2
        var positionX: CGFloat = 0
        let positionY = spacing
        for button in positioned {
            positionX += spacing
            button.position = CGPointMake(positionX + button.size.width / 2, positionY + button.size.height / 2)
            positionX += button.size.width
            positionX += spacing
        }
        
        if opened {
            position.x = 0
        } else {
            closeX = -(openButton.size.width + spacing * 2) * CGFloat(integerLiteral: buttons.count)
            position.x = closeX
        }
    }
    
    public func appendButton(button: GameButton) {
        buttons.append(button)
        addChild(button)
    }
    
    private func toggleOpenState() {
        let slideAction: SKAction
        let rotateAction: SKAction
        let duration = 0.3
        if opened {
            opened = false
            slideAction = SKAction.moveTo(CGPointMake(closeX, position.y), duration: duration)
            rotateAction = SKAction.rotateByAngle(radians(180.0), duration: duration)
        } else {
            opened = true
            slideAction = SKAction.moveTo(CGPointMake(0, position.y), duration: duration)
            rotateAction = SKAction.rotateByAngle(radians(-180.0), duration: duration)
        }
        
        openButton.runAction(rotateAction)
        runAction(slideAction)
    }
}