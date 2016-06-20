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

private let BackgroundCornerRadius: CGFloat = 5

class HintButtonTray: GameView {
    private(set) var hintButton: GameButton!
    private var border: SKShapeNode!
    
    override func loadContent() {
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, -1, 0)
        CGPathAddLineToPoint(path, nil, size.width, 0)
        CGPathAddLineToPoint(path, nil, size.width, size.height)
        CGPathAddLineToPoint(path, nil, -1, size.height)
        CGPathCloseSubpath(path)
        border = SKShapeNode(path: path)
        border.fillColor = TenPairTheme.currentTheme.defaultNumberTileColor!
        #if os(iOS)
            border.strokeColor = UIColor.whiteColor()
        #else
            border.strokeColor = NSColor.whiteColor()
        #endif
        border.glowWidth = 1
        addChild(border)
        
        hintButton = GameButton(imageNamed: "hint")
        hintButton.size = CGSizeMake(44, 44)
        
        addChild(hintButton)
        
        super.loadContent()
    }
    
    override func positionContent() {
        super.positionContent()
        
        hintButton.position = CGPointMake(size.width / 2, size.height / 2)
    }
}
