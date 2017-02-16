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

class FieldStatusView: View {
    private let linesIcon = SKSpriteNode(imageNamed: "lines")
    private let linesLabel = SKLabelNode()
    private let tilesIcon = SKSpriteNode(imageNamed: "tile")
    private let tilesLabel = SKLabelNode()
    private var knownLines: Int = 0
    private var knownTiles: Int = 0

    override func load() {
        linesIcon.anchorPoint = CGPoint.zero
        linesIcon.colorBlendFactor = 1
        addChild(linesIcon)
        
        linesLabel.fontName = "ChalkboardSE-Bold"
        linesLabel.text = "x000"
        linesLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.baseline
        linesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        addChild(linesLabel)
        
        tilesIcon.anchorPoint = CGPoint.zero
        tilesIcon.colorBlendFactor = 1
        addChild(tilesIcon)
        
        tilesLabel.fontName = "ChalkboardSE-Bold"
        tilesLabel.text = "x000"
        tilesLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.baseline
        tilesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        addChild(tilesLabel)
        
        positionChildren()
    }
    
    override func positionChildren() {
        let usedHeight = size.height / 3
        linesLabel.fontSize = usedHeight
        tilesLabel.fontSize = usedHeight
        
        linesIcon.size = CGSize(width: usedHeight, height: usedHeight)
        tilesIcon.size = CGSize(width: usedHeight, height: usedHeight)

        let totalWidth = linesIcon.size.width + linesLabel.frame.size.width + 10 + tilesIcon.size.width + tilesLabel.frame.size.width
        var xOffset = (size.width - totalWidth) / 2
        
        linesIcon.position = CGPoint(x: xOffset, y: (size.height - linesIcon.size.height) / 2)
        xOffset += linesIcon.size.width
        linesLabel.position = CGPoint(x: xOffset, y: (size.height - linesLabel.frame.size.height) / 2)
        xOffset += linesLabel.frame.size.width
        
        xOffset += 10
        tilesIcon.position = CGPoint(x: xOffset, y: (size.height - tilesIcon.size.height) / 2)
        xOffset += tilesIcon.size.width
        tilesLabel.position = CGPoint(x: xOffset, y: (size.height - tilesLabel.frame.size.height) / 2)
    }
    
    override func set(color: SKColor, for attribute: Appearance.Attribute) {
        super.set(color: color, for: attribute)
        
        if attribute == .foreground {
            linesIcon.color = color
            linesLabel.fontColor = color
            tilesIcon.color = color
            tilesLabel.fontColor = color
        }
    }
}
