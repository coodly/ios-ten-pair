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
    var tileSize = CGSizeZero
    var verticalLines = [SKShapeNode]()
    var horizontalLines = [SKShapeNode]()
    var lastHandledTopLine = -1
    
    func update(totalSize: CGSize, numberOfLines: Int, numberOfTiles: Int) {
        updateBackground(totalSize, tileSize: tileSize, numberOfLines: numberOfLines, numberOfTiles: numberOfTiles)
        updateVerticalLines(totalSize, tileSize: tileSize)
    }
    
    private func updateVerticalLines(totalSize: CGSize, tileSize: CGSize) {
        if verticalLines.count == 0 {
            for _ in 0...8 {
                let line = createLine()
                
                verticalLines.append(line)
            }
        }
        
        for index in 0...8 {
            let line = verticalLines[index]
            let lineX = tileSize.width + CGFloat(index) * tileSize.width
            
            let linePath = UIBezierPath()
            linePath.moveToPoint(CGPointMake(lineX, 0))
            linePath.addLineToPoint(CGPointMake(lineX, totalSize.height))
            line.path = linePath.CGPath
        }
    }
    
    func updateWithTopLine(topLine: Int, totalSize: CGSize) {
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
            let linePath = UIBezierPath()
            linePath.moveToPoint(CGPointMake(0, lineY))
            linePath.addLineToPoint(CGPointMake(tileSize.width * 9, lineY))
            line.path = linePath.CGPath
        }
    }
    
    private func createLine() -> SKShapeNode {
        let line = SKShapeNode()
        line.lineWidth = 2
        line.fillColor = TenPairTheme.currentTheme.backgroundColor!
        line.antialiased = false
        addChild(line)
        return line
    }
    
    private func updateBackground(totalSize: CGSize, tileSize: CGSize, numberOfLines: Int, numberOfTiles: Int) {
        let fieldBottom = totalSize.height - CGFloat(numberOfLines) * tileSize.height
        let lastRowRemainder = numberOfTiles % 9
        
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(0, fieldBottom))
        path.addLineToPoint(CGPointMake(0, totalSize.height))
        path.addLineToPoint(CGPointMake(totalSize.width, totalSize.height))
        if lastRowRemainder == 0 {
            path.addLineToPoint(CGPointMake(totalSize.width, fieldBottom))
        } else {
            let bottomOneLineOff = fieldBottom + tileSize.height
            path.addLineToPoint(CGPointMake(totalSize.width, bottomOneLineOff))
            
            let lastXOffset = CGFloat(lastRowRemainder) * tileSize.width
            
            path.addLineToPoint(CGPointMake(lastXOffset, bottomOneLineOff))
            path.addLineToPoint(CGPointMake(lastXOffset, fieldBottom))
        }
        path.closePath()
        
        self.path = path.CGPath
    }
}