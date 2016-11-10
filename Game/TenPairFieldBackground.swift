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

class TenPairFieldBackground: SKShapeNode {
    var tileSize = CGSize.zero
    var verticalLines = [SKShapeNode]()
    var horizontalLines = [SKShapeNode]()
    var lastHandledTopLine = -1
    
    func update(_ totalSize: CGSize, numberOfLines: Int, numberOfTiles: Int) {
        updateBackground(totalSize, tileSize: tileSize, numberOfLines: numberOfLines, numberOfTiles: numberOfTiles)
        updateVerticalLines(totalSize, tileSize: tileSize)
    }
    
    fileprivate func updateVerticalLines(_ totalSize: CGSize, tileSize: CGSize) {
        if verticalLines.count == 0 {
            for _ in 0...8 {
                let line = createLine()
                
                verticalLines.append(line)
            }
        }
        
        for index in 0...8 {
            let line = verticalLines[index]
            let lineX = tileSize.width + CGFloat(index) * tileSize.width
            
            let path = CGMutablePath()
            path.move(to: CGPoint(x: lineX, y: 0))
            path.addLine(to: CGPoint(x: lineX, y: totalSize.width))
            line.path = path
        }
    }
    
    func updateWithTopLine(_ topLine: Int, totalSize: CGSize) {
        if lastHandledTopLine == topLine {
            return
        }
        
        lastHandledTopLine = topLine
        
        let start = max(0, topLine - 5)
        for index in 0...40 {
            let lineNumber = start + index
            var line:SKShapeNode
            if horizontalLines.count > index {
                line = horizontalLines[index]
            } else {
                line = createLine()
                horizontalLines.append(line)
            }
            
            let lineY = totalSize.height - CGFloat(lineNumber) * tileSize.height
            let linePath = CGMutablePath()
            linePath.move(to: CGPoint(x: 0, y: lineY))
            linePath.addLine(to: CGPoint(x: totalSize.width * 9, y: lineY))
            line.path = linePath
        }
    }
    
    fileprivate func createLine() -> SKShapeNode {
        let line = SKShapeNode()
        line.lineWidth = 2
        line.fillColor = TenPairTheme.currentTheme.backgroundColor!
        line.isAntialiased = false
        addChild(line)
        return line
    }
    
    fileprivate func updateBackground(_ totalSize: CGSize, tileSize: CGSize, numberOfLines: Int, numberOfTiles: Int) {
        let fieldBottom = totalSize.height - CGFloat(numberOfLines) * tileSize.height
        let lastRowRemainder = numberOfTiles % 9
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: fieldBottom))
        path.addLine(to: CGPoint(x: 0, y: totalSize.width))
        path.addLine(to: CGPoint(x: totalSize.width, y: totalSize.height))

        if lastRowRemainder == 0 {
            path.addLine(to: CGPoint(x: totalSize.width, y: fieldBottom))
        } else {
            let bottomOneLineOff = fieldBottom + tileSize.height
            path.addLine(to: CGPoint(x: totalSize.width, y: bottomOneLineOff))
            
            let lastXOffset = CGFloat(lastRowRemainder) * tileSize.width

            path.addLine(to: CGPoint(x: lastXOffset, y: bottomOneLineOff))
            path.addLine(to: CGPoint(x: lastXOffset, y: fieldBottom))
        }
        path.closeSubpath()
        
        self.path = path
    }
}
