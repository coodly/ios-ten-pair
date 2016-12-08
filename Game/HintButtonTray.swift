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

class HintButtonTray: View {
    fileprivate(set) var hintButton: Button!
    fileprivate var border: SKShapeNode!
    
    override func loadContent() {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -1, y: 0))
        path.addLine(to: CGPoint(x: size.width, y: 0))
        path.addLine(to: CGPoint(x: size.width, y: size.height))
        path.addLine(to: CGPoint(x: -1, y: size.height))
        path.closeSubpath()
        border = SKShapeNode(path: path)
        border.fillColor = TenPairTheme.currentTheme.defaultNumberTileColor!
        border.strokeColor = SKColor.white
        border.glowWidth = 1
        addChild(border)
        
        hintButton = Button(imageNamed: "hint")
        hintButton.size = CGSize(width: 44, height: 44)
        
        addChild(hintButton)
        
        super.loadContent()
    }
    
    override func positionContent() {
        super.positionContent()
        
        hintButton.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }
}
