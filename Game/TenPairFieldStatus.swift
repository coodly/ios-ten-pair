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

class TenPairFieldStatus: GameView {
    let linesIcon = SKSpriteNode(imageNamed: "lines")
    let linesLabel = SKLabelNode()
    let tilesIcon = SKSpriteNode(imageNamed: "tile")
    let tilesLabel = SKLabelNode()
    var knownLines: Int = 0
    var knownTiles: Int = 0
    
    override func loadContent() {
        linesIcon.color = TenPairTheme.currentTheme.tintColor!
        linesIcon.anchorPoint = CGPointZero
        linesIcon.size = CGSizeMake(linesIcon.size.width / 2, linesIcon.size.height / 2)
        linesIcon.colorBlendFactor = 1
        addChild(linesIcon)
        
        linesLabel.fontColor = TenPairTheme.currentTheme.tintColor!
        linesLabel.fontName = "ChalkboardSE-Bold"
        linesLabel.text = "x000"
        linesLabel.fontSize = 14
        linesLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Baseline
        linesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        addChild(linesLabel)
        
        tilesIcon.color = TenPairTheme.currentTheme.tintColor!
        tilesIcon.anchorPoint = CGPointZero
        tilesIcon.size = CGSizeMake(tilesIcon.size.width / 2, tilesIcon.size.height / 2)
        tilesIcon.colorBlendFactor = 1
        addChild(tilesIcon)

        tilesLabel.fontColor = TenPairTheme.currentTheme.tintColor!
        tilesLabel.fontName = "ChalkboardSE-Bold"
        tilesLabel.text = "x000"
        tilesLabel.fontSize = 14
        tilesLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Baseline
        tilesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        addChild(tilesLabel)
        
        positionContent()
    }
    
    override func positionContent() {
        let totalWidth = linesIcon.size.width + linesLabel.frame.size.width + 10 + tilesIcon.size.width + tilesLabel.frame.size.width
        var xOffset = (size.width - totalWidth) / 2
        
        linesIcon.position = CGPointMake(xOffset, (size.height - linesIcon.size.height) / 2)
        xOffset += linesIcon.size.width
        linesLabel.position = CGPointMake(xOffset, (size.height - linesLabel.frame.size.height) / 2)
        xOffset += linesLabel.frame.size.width

        xOffset += 10
        tilesIcon.position = CGPointMake(xOffset, (size.height - tilesIcon.size.height) / 2)
        xOffset += tilesIcon.size.width
        tilesLabel.position = CGPointMake(xOffset, (size.height - tilesLabel.frame.size.height) / 2)
    }
    
    func updateLines(lines: Int) {
        knownLines = lines
        linesLabel.text = "x\(lines)"
        positionContent()
    }
    
    func updateTiles(tiles: Int) {
        knownTiles = tiles
        tilesLabel.text = "x\(tiles)"
        positionContent()
    }
    
    func addToLines(added: Int) {
        updateLines(knownLines + added)
    }
    
    func addToTiles(added: Int) {
        updateTiles(knownTiles + added)
    }
}