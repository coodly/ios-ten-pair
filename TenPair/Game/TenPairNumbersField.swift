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
import UIKit

let TenPairColumns: Int = 9
let TenPairRowHideTime: NSTimeInterval = 0.3
let TenPairHideTileAction = SKAction.hide()
let TenPairUnhideTileAction = SKAction.unhide()
let TenPairRemoveTileAction = SKAction.removeFromParent()

class TenPairNumbersField: GameScrollViewContained {
    var presentedNumbers: [Int] = []
    var tileSize = CGSizeZero
    var selectedTile: TenPairNumberTile?
    var selectedIndex: Int = -1
    var fieldStatus: TenPairFieldStatus?
    var lastHandledVisible = CGRectZero
    var tilesInUse = [Int: TenPairNumberTile]()
    var reusableTiles = [TenPairNumberTile]()
    var gameWonAction: SKAction?
    let background = TenPairFieldBackground()
    
    override func loadContent() {
        name = "TenPairNumbersField"
        
        userInteractionEnabled = true
        
        var tileEdge = 10
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            tileEdge = 35
        } else {
            tileEdge = 50   
        }
        
        tileSize = CGSizeMake(CGFloat(tileEdge), CGFloat(tileEdge))

        background.tileSize = tileSize
        background.fillColor = TenPairTheme.currentTheme.consumedTileColor!
        addChild(background)

        notifySizeChanged()
    }
    
    func reloadNumbers(completion: SKAction = SKAction.waitForDuration(0)) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            let filtered = self.presentedNumbers.filter({ (number) -> Bool in
                let num = number as Int
                return num != 0
            })
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.presentedNumbers += filtered
                self.lastHandledVisible = CGRectZero
                self.notifySizeChanged()
                self.updateStatusLines()
                self.fieldStatus!.updateTiles(filtered.count * 2)
                self.runAction(completion)
            })
        })
    }
    
    func tappedAt(location: CGPoint) {
        if !userInteractionEnabled {
            return
        }
        
        let nodes = nodesAtPoint(location)
        let tile = tileInArray(nodes)
        
        if tile == nil {
            return
        }
        
        let tileIndex = indexOfNode(tile)
        
        if tile.number == 0 {
            return
        } else if selectedIndex == -1 {
            selectedTile = tile
            selectedIndex = tileIndex
            tile.markSelected()
            return
        } else if (selectedIndex == tileIndex) {
            tile.markUnselected()
            selectedTile = nil
            selectedIndex = -1
            return
        }
        
        userInteractionEnabled = false
        tile.markSelected()
        
        let indexOne = selectedIndex
        let indexTwo = tileIndex
        
        if !TenPairNumberPathFinder.hasClearPath([indexOne, indexTwo], inField: presentedNumbers) {
            executeFailureAnimationWithTiles(selectedTile, two: tile)
            return
        }
        
        let valueOne = presentedNumbers[indexOne]
        let valueTwo = presentedNumbers[indexTwo]
        
        if valueOne != valueTwo && valueOne + valueTwo != 10 {
            executeFailureAnimationWithTiles(selectedTile, two: tile)
            return
        }
        
        executeConsumeWithTiles(selectedTile, two: tile, atIndexOne: indexOne, atIndexTwo: indexTwo)
    }
    
    func tileInArray(nodes: [AnyObject]) -> TenPairNumberTile! {
        for node in Array(nodes.reverse()) {
            if node is TenPairNumberTile {
                let tile = node as! TenPairNumberTile
                if !tile.hidden {
                    return tile
                }
            }
        }
        
        return nil
    }
    
    func executeConsumeWithTiles(one: TenPairNumberTile?, two:TenPairNumberTile, atIndexOne: Int, atIndexTwo: Int) {
        let consumeActions = [
            SKAction.colorizeWithColor(TenPairTheme.currentTheme.successTileColor!, colorBlendFactor: 1, duration: 0.3),
            SKAction.runAction(SKAction.hide(), onChildWithName: "numberLabel"),
            SKAction.colorizeWithColor(TenPairTheme.currentTheme.consumedTileColor!, colorBlendFactor: 1, duration: 0.3),
        ]
        
        if let consumedOne = one {
            let zeroOneAction = SKAction.runBlock({ () -> Void in
                consumedOne.number = 0
            })
            
            var firstActions = Array(consumeActions)
            firstActions.append(zeroOneAction)
            
            let firstSequence = SKAction.sequence(firstActions)
            
            consumedOne.backgroundNode!.runAction(firstSequence)
        }

        let zeroTwoAndCompleteActio = SKAction.runBlock { () -> Void in
            two.number = 0
            self.selectedTile = nil
            self.selectedIndex = -1
            self.presentedNumbers[atIndexOne] = 0
            self.presentedNumbers[atIndexTwo] = 0
            let lines = TenPairEmptyLinesSearch.emptyLinesWithCheckPoints([atIndexOne, atIndexTwo], field: self.presentedNumbers)
            if lines.count > 0 {
                self.executeRemovingLines(lines)
            } else {
                self.userInteractionEnabled = true
            }
            
            self.fieldStatus!.addToTiles(-2)
        }

        var secondActions = Array(consumeActions)
        secondActions.append(zeroTwoAndCompleteActio)
        
        let secondSequence = SKAction.sequence(secondActions)
        
        two.backgroundNode!.runAction(secondSequence)
    }
    
    func executeRemovingLines(lins: [Int]) {
        var lines = lins
        lines.sortInPlace()
        lines = Array(lines.reverse())
        for line in lines {
            let removeStart = line * TenPairColumns
            let removeEnd = removeStart + TenPairColumns
            presentedNumbers.removeRange(Range(start: removeStart, end: removeEnd))
            for var index = removeStart; index < removeEnd; index++ {
                if let tile = tilesInUse.removeValueForKey(index) {
                    tile.runAction(TenPairRemoveTileAction)
                }
            }
            
            reindexTilesStaringFrom(removeEnd)
        }
        
        fieldStatus!.addToLines(-lines.count)
        let lastHandled = lastHandledVisible
        lastHandledVisible = CGRectZero
        
        ensureVisibleCovered(lastHandled, animated: true, completionAction: SKAction.runBlock({ () -> Void in
            self.userInteractionEnabled = true
            self.notifySizeChanged()
            if self.numberOfLines() == 0 {
                self.runAction(self.gameWonAction!)
            }
        }))
    }
    
    func reindexTilesStaringFrom(reindexStart: Int) {
        var indexes = Array(tilesInUse.keys)
        indexes.sortInPlace()
        let maxIndex = indexes.last
        for var index = reindexStart; index <= maxIndex; index++ {
            if let tile = tilesInUse.removeValueForKey(index) {
                tilesInUse[index - TenPairColumns] = tile
            }
        }
    }
    
    func executeFailureAnimationWithTiles(one: TenPairNumberTile?, two: TenPairNumberTile) {
        let shakeActions = [
            SKAction.colorizeWithColor(TenPairTheme.currentTheme.errorTileColor!, colorBlendFactor: 1, duration: 0.3),
            SKAction.moveBy(CGVectorMake(2, 0), duration: 0.1),
            SKAction.moveBy(CGVectorMake(-4, 0), duration: 0.1),
            SKAction.moveBy(CGVectorMake(2, 0), duration: 0.1),
            SKAction.colorizeWithColor(TenPairTheme.currentTheme.defaultNumberTileColor!, colorBlendFactor: 1, duration: 0.3),
        ]
        
        if let animatedOne = one {
            let unmarkFirstAction = SKAction.runBlock { () -> Void in
                animatedOne.markUnselected()
            }

            var firstActions = Array(shakeActions)
            firstActions.append(unmarkFirstAction)

            let firstSequence = SKAction.sequence(firstActions)
            
            animatedOne.backgroundNode!.runAction(firstSequence)
        }
        
        let unmarkSecondAndResetSelectedAction = SKAction.runBlock { () -> Void in
            two.markUnselected()
            self.selectedTile = nil
            self.selectedIndex = -1
            self.userInteractionEnabled = true
        }
        
        var secondActions = Array(shakeActions)
        secondActions.append(unmarkSecondAndResetSelectedAction)
        
        let secondSequence = SKAction.sequence(secondActions)
        
        two.backgroundNode!.runAction(secondSequence)
    }
    
    func indexOfNode(node: TenPairNumberTile) -> Int {
        let column = Int(node.position.x / tileSize.width)
        let row = Int((size.height - node.position.y - (tileSize.height / 2)) / tileSize.height)
        let index = row * TenPairColumns + column
        return index
    }
    
    func updateFieldStatus() {
        updateStatusLines()
        updateStatusTiles()
    }
    
    func updateStatusLines() {
        let lines = numberOfLines()
        fieldStatus?.updateLines(lines)
    }
    
    func numberOfLines() -> Int {
        return Int(ceilf(Float(presentedNumbers.count) / Float(TenPairColumns)))
    }
    
    func updateStatusTiles() {
        let nonZero = presentedNumbers.filter({ (number) -> Bool in
            let num = number as Int
            return num != 0
        })
        fieldStatus?.updateTiles(nonZero.count)
    }
    
    override func scrolledVisibleTo(visibleFrame: CGRect) {
        userInteractionEnabled = true
        
        if runningActions() {
            return
        }
        
        if CGRectEqualToRect(lastHandledVisible, visibleFrame) {
            return
        }
        
        var toCheck = CGRectZero
        if CGRectIsEmpty(lastHandledVisible) {
            toCheck = visibleFrame
        } else if lastHandledVisible.height != visibleFrame.height {
            toCheck = visibleFrame
        } else {
            let handledTop = lastHandledVisible.maxY
            let handledBottom = lastHandledVisible.minY
            let visibleTop = visibleFrame.maxY
            let visibleBottom = visibleFrame.minY

            toCheck.size.width = visibleFrame.width
            
            if handledTop > visibleTop {
                toCheck.origin.y = visibleBottom
                toCheck.size.height = handledBottom - visibleBottom
            } else {
                toCheck.origin.y = handledTop
                toCheck.size.height = visibleTop - handledTop
            }
        }
        
        let topY = size.height - (visibleFrame.origin.y + visibleFrame.height)
        let topLine = lineForY(topY)
        background.updateWithTopLine(topLine, totalSize:size)
        
        lastHandledVisible = visibleFrame
        ensureVisibleCovered(toCheck)
        removeHiddenTiles(visibleFrame)
    }
        
    func removeHiddenTiles(visibleFrame: CGRect) {
        var toRemove = [Int]()
        
        for (tileIndex, tile) in tilesInUse {
            var frame = CGRectZero
            frame.origin = tile.position
            frame.size = tile.size
            if CGRectIntersectsRect(frame, visibleFrame) {
                continue
            }
            
            toRemove.append(tileIndex)
        }
        
        for index in toRemove {
            if  index == selectedIndex {
                selectedTile = nil
            }
            
            let tile = tilesInUse.removeValueForKey(index)!
            tile.runAction(TenPairHideTileAction)
            reusableTiles.append(tile)
        }
    }
    
    func ensureVisibleCovered(visible: CGRect, animated: Bool = false, completionAction: SKAction = SKAction.waitForDuration(0)) {
        let topY = size.height - (visible.origin.y + visible.size.height)
        let topLine = lineForY(topY)
        let startIndex = topLine * TenPairColumns
        for var index = startIndex; index < presentedNumbers.count; index++ {
            let tileFrame = probeTileForIndex(index, animated:animated)
            let tileTop = tileFrame.origin.y + tileFrame.size.height
            if tileTop < visible.origin.y {
                break
            }
        }
        
        let waitAction = SKAction.waitForDuration(TenPairRowHideTime + 0.1)
        let sequence = SKAction.sequence([waitAction, completionAction])
        runAction(sequence)
    }
    
    func probeTileForIndex(index: Int, animated: Bool) -> CGRect {
        let column = CGFloat(index % TenPairColumns)
        let row = CGFloat(index / TenPairColumns)
        let position = CGPointMake(column * tileSize.width, size.height - tileSize.height - row * tileSize.height)
        let probe = CGPointMake(position.x + tileSize.width / 2, position.y + tileSize.height / 2)
        var tile: TenPairNumberTile
        let number = presentedNumbers[index]

        var frame = CGRectZero
        frame.origin = position
        frame.size = tileSize
        var tileCreated = false
        
        if number == 0 {
            if let tileAtProbe = tilesInUse[index] {
                tileAtProbe.runAction(TenPairHideTileAction)
                tilesInUse.removeValueForKey(index)
                reusableTiles.append(tileAtProbe)
            }
            
            return frame
        } else if let tileAtProbe = tilesInUse[index] {
            tile = tileAtProbe
        } else {
            tileCreated = true
            var sprite: TenPairNumberTile
            if let reused = reusableTiles.last {
                reusableTiles.removeLast()
                sprite = reused
                reused.runAction(TenPairUnhideTileAction)
            } else {
                sprite = TenPairNumberTile()
                addChild(sprite)
            }
            
            sprite.anchorPoint = CGPointZero
            sprite.number = number
            sprite.size = tileSize
            sprite.defaultPresentaton()
            if selectedIndex == index {
                sprite.markSelected()
                selectedTile = sprite
            }
            
            tile = sprite
            tilesInUse[index] = sprite
        }
        
        if animated && !tileCreated {
            let moveAction = SKAction.moveTo(position, duration: TenPairRowHideTime)
            tile.runAction(moveAction)
        } else {
            tile.position = position
        }
        
        return frame
    }
    
    func lineForY(positionY: CGFloat) -> Int {
        return Int(positionY / tileSize.height)
    }
    
    func notifySizeChanged() {
        let lines = numberOfLines()
        
        let heigth = max(size.height, fieldHeight())
        
        size = CGSizeMake(CGFloat(TenPairColumns) * tileSize.width, heigth)
        
        background.update(size, numberOfLines: lines, numberOfTiles: presentedNumbers.count)
        
        scrollView?.contentSizeChanged()
    }
    
    func restartGame() {
        lastHandledVisible = CGRectZero
        for (key, value) in tilesInUse {
            let tile = value as TenPairNumberTile
            tile.runAction(TenPairHideTileAction)
            reusableTiles.append(tile)
        }
        tilesInUse.removeAll(keepCapacity: true)
        updateFieldStatus()
        notifySizeChanged()
    }
    
    func fieldHeight () -> CGFloat {
        return CGFloat(numberOfLines()) * tileSize.height
    }
    
    func bottomOffset() -> CGFloat {
        return size.height - fieldHeight()
    }
    
    override func presentationInsets() -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, -bottomOffset(), 0)
    }
    
    func dumpRange(start: Int, end: Int) {
        for index in start...end {
            if index % TenPairColumns == 0 {
                print("")
            }

            if index >= presentedNumbers.count {
                return
            }
            
            let number = presentedNumbers[index]
            print("\(number) ", terminator: "")
        }
    }
    
    func startOfLineForIndex(index: Int) -> Int {
        return index - index % TenPairColumns
    }
    
    func endOfLineForIndex(index: Int) -> Int {
        return index + (TenPairColumns - index % TenPairColumns)
    }
    
    func runningActions() -> Bool {
        for child in children {
            if child.hasActions() {
                return true
            }
        }
        
        return false
    }
}