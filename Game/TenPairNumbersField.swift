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
import SWLogger

private let TenPairRowHideTime: TimeInterval = 0.3
private let TenPairHideTileAction = SKAction.hide()
private let TenPairUnhideTileAction = SKAction.unhide()
private let TenPairRemoveTileAction = SKAction.removeFromParent()
private let SidesSpacing: CGFloat = 10 * 2
private let MaxPadTileWidth: CGFloat = 50
private let MaxPhoneTileWidth: CGFloat = 35

class TenPairNumbersField: GameScrollViewContained {
    var runningOn = Platform.mac
    var presentedNumbers = [Int]()
    var tileSize = CGSize.zero {
        didSet {
            background.tileSize = tileSize
            background.lastHandledTopLine = -1
        }
    }
    fileprivate var selectedTile: TenPairNumberTile?
    var selectedIndex: Int = -1
    var fieldStatus: TenPairFieldStatus?
    var lastHandledVisible = CGRect.zero
    var tilesInUse = [Int: TenPairNumberTile]()
    var reusableTiles = [TenPairNumberTile]()
    var gameWonAction: SKAction?
    let background = TenPairFieldBackground()
    var presentationWidth: CGFloat = 0 {
        didSet {
            guard oldValue != presentationWidth else {
                return
            }
            
            let tileWidth = (presentationWidth - SidesSpacing) / CGFloat(integerLiteral: NumberOfColumns)
            let maxWidth = runningOn == .phone ? MaxPhoneTileWidth : MaxPadTileWidth
            let rounded = min(round(tileWidth), maxWidth)
            let nextSize = CGSize(width: rounded, height: rounded)
            if nextSize.equalTo(tileSize) {
                return
            }
            
            tileSize = nextSize
            
            reusableTiles.removeAll()
            for (_, tile) in tilesInUse {
                tile.removeFromParent()
            }
            tilesInUse.removeAll()
            
            self.lastHandledVisible = CGRect.zero
            self.notifySizeChanged()
        }
    }
    fileprivate var userInputAllowed = true
    
    override func loadContent() {
        name = "TenPairNumbersField"
        
        userInputAllowed = true
        
        background.fillColor = TenPairTheme.currentTheme.consumedTileColor!
        addChild(background)

        notifySizeChanged()
    }
    
    func reloadNumbers(_ completion: SKAction = SKAction.wait(forDuration: 0)) {
        inBackground() {
            let filtered = self.presentedNumbers.filter({ $0 != 0 })
            
            onMainThread() {
                self.presentedNumbers += filtered
                self.lastHandledVisible = CGRect.zero
                self.background.lastHandledTopLine = -1
                self.notifySizeChanged()
                self.updateStatusLines()
                self.fieldStatus!.updateTiles(filtered.count * 2)
                self.run(completion)
            }
        }
    }
    
    func tappedAt(_ location: CGPoint) {
        if !userInputAllowed {
            return
        }
        
        let checked = nodes(at: location)
        guard let tile = tileInArray(checked, tappedAt: location) else {
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
        
        userInputAllowed = false
        tile.markSelected()
        
        let indexOne = selectedIndex
        let indexTwo = tileIndex
        
        guard TenPairNumberPathFinder.hasClearPath([indexOne, indexTwo], inField: presentedNumbers) else {
            executeFailureAnimationWithTiles(selectedTile, two: tile)
            return
        }
        
        let valueOne = presentedNumbers[indexOne]
        let valueTwo = presentedNumbers[indexTwo]
        
        guard valueOne == valueTwo || valueOne + valueTwo == 10 else {
            executeFailureAnimationWithTiles(selectedTile, two: tile)
            return
        }
        
        executeConsumeWithTiles(selectedTile, two: tile, atIndexOne: indexOne, atIndexTwo: indexTwo)
    }
    
    func tileInArray(_ nodes: [AnyObject], tappedAt: CGPoint) -> TenPairNumberTile! {
        for node in Array(nodes.reversed()) {
            guard let tile = node as? TenPairNumberTile, !tile.isHidden else {
                continue
            }
            
            var frame = CGRect.zero
            frame.origin = tile.position
            frame.size = tile.size
            
            guard frame.contains(tappedAt) else {
                continue
            }
            
            return tile
        }
        
        return nil
    }
    
    func executeConsumeWithTiles(_ one: TenPairNumberTile?, two:TenPairNumberTile, atIndexOne: Int, atIndexTwo: Int) {
        let consumeActions = [
            SKAction.colorize(with: TenPairTheme.currentTheme.successTileColor!, colorBlendFactor: 1, duration: 0.3),
            SKAction.run(SKAction.hide(), onChildWithName: "numberLabel"),
            SKAction.colorize(with: TenPairTheme.currentTheme.consumedTileColor!, colorBlendFactor: 1, duration: 0.3),
        ]
        
        if let consumedOne = one {
            let zeroOneAction = SKAction.run({ () -> Void in
                consumedOne.number = 0
            })
            
            var firstActions = Array(consumeActions)
            firstActions.append(zeroOneAction)
            
            let firstSequence = SKAction.sequence(firstActions)
            
            consumedOne.backgroundNode!.run(firstSequence)
        }

        let zeroTwoAndCompleteAction = SKAction.run() {
            two.number = 0
            self.selectedTile = nil
            self.selectedIndex = -1
            self.presentedNumbers[atIndexOne] = 0
            self.presentedNumbers[atIndexTwo] = 0
            let lines = TenPairEmptyLinesSearch.emptyRangesWithCheckPoints([atIndexOne, atIndexTwo], field: self.presentedNumbers)
            if lines.count > 0 {
                self.executeRemovingLines(lines)
            } else {
                self.userInputAllowed = true
            }
            
            self.fieldStatus!.addToTiles(-2)
        }

        var secondActions = Array(consumeActions)
        secondActions.append(zeroTwoAndCompleteAction)
        
        let secondSequence = SKAction.sequence(secondActions)
        
        two.backgroundNode!.run(secondSequence)
    }
    
    func executeRemovingLines(_ lins: [CountableRange<Int>]) {
        let lines = lins.sorted(by: { $0.lowerBound > $1.lowerBound })
        for removed in lines {
            presentedNumbers.removeSubrange(removed)
            for index in removed {
                if let tile = tilesInUse.removeValue(forKey: index) {
                    tile.run(TenPairRemoveTileAction)
                }
            }
            
            reindexTilesStaringFrom(removed.upperBound)
        }
        
        fieldStatus!.addToLines(-lines.count)
        let lastHandled = lastHandledVisible
        lastHandledVisible = CGRect.zero
        
        ensureVisibleCovered(lastHandled, animated: true, completionAction: SKAction.run({ () -> Void in
            self.userInputAllowed = true
            self.notifySizeChanged()
            if self.gameCompleted() {
                self.run(self.gameWonAction!)
            }
        }))
    }
    
    func reindexTilesStaringFrom(_ reindexStart: Int) {
        var indexes = Array(tilesInUse.keys)
        indexes.sort()
        guard let maxIndex = indexes.last else {
            return
        }
        
        if maxIndex < reindexStart {
            return
        }
        
        for index in reindexStart...maxIndex {
            if let tile = tilesInUse.removeValue(forKey: index) {
                tilesInUse[index - NumberOfColumns] = tile
            }
        }
    }
    
    func executeFailureAnimationWithTiles(_ one: TenPairNumberTile?, two: TenPairNumberTile) {
        let shakeActions = [
            SKAction.colorize(with: TenPairTheme.currentTheme.errorTileColor!, colorBlendFactor: 1, duration: 0.3),
            SKAction.move(by: CGVector(dx: 2, dy: 0), duration: 0.1),
            SKAction.move(by: CGVector(dx: -4, dy: 0), duration: 0.1),
            SKAction.move(by: CGVector(dx: 2, dy: 0), duration: 0.1),
            SKAction.colorize(with: TenPairTheme.currentTheme.defaultNumberTileColor!, colorBlendFactor: 1, duration: 0.3),
        ]
        
        if let animatedOne = one {
            let unmarkFirstAction = SKAction.run { () -> Void in
                animatedOne.markUnselected()
            }

            var firstActions = Array(shakeActions)
            firstActions.append(unmarkFirstAction)

            let firstSequence = SKAction.sequence(firstActions)
            
            animatedOne.backgroundNode!.run(firstSequence)
        }
        
        let unmarkSecondAndResetSelectedAction = SKAction.run { () -> Void in
            two.markUnselected()
            self.selectedTile = nil
            self.selectedIndex = -1
            self.userInputAllowed = true
        }
        
        var secondActions = Array(shakeActions)
        secondActions.append(unmarkSecondAndResetSelectedAction)
        
        let secondSequence = SKAction.sequence(secondActions)
        
        two.backgroundNode!.run(secondSequence)
    }
    
    func indexOfNode(_ node: TenPairNumberTile) -> Int {
        let column = Int(node.position.x / tileSize.width)
        let row = Int((size.height - node.position.y - (tileSize.height / 2)) / tileSize.height)
        let index = row * NumberOfColumns + column
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
    
    fileprivate func gameCompleted() -> Bool {
        if numberOfLines() > 1 {
            return false
        }
        
        return presentedNumbers.filter({ $0 != 0}).count == 0
    }
    
    func numberOfLines() -> Int {
        return Int(ceilf(Float(presentedNumbers.count) / Float(NumberOfColumns)))
    }
    
    func updateStatusTiles() {
        let nonZero = presentedNumbers.filter({ (number) -> Bool in
            let num = number as Int
            return num != 0
        })
        fieldStatus?.updateTiles(nonZero.count)
    }
    
    override func scrolledVisibleTo(_ visibleFrame: CGRect) {
        userInputAllowed = true
        
        if runningActions() {
            return
        }
        
        if lastHandledVisible.equalTo(visibleFrame) {
            return
        }
        
        var toCheck = CGRect.zero
        if lastHandledVisible.isEmpty {
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
        
        if toCheck.height > visibleFrame.height {
            toCheck = visibleFrame
        }
        
        let topY = size.height - (visibleFrame.origin.y + visibleFrame.height)
        let topLine = lineForY(topY)
        background.updateWithTopLine(topLine, totalSize:size)
        
        lastHandledVisible = visibleFrame
        ensureVisibleCovered(toCheck)
        removeHiddenTiles(visibleFrame)
    }
        
    func removeHiddenTiles(_ visibleFrame: CGRect) {
        var toRemove = [Int]()
        
        for (tileIndex, tile) in tilesInUse {
            var frame = CGRect.zero
            frame.origin = tile.position
            frame.size = tile.size
            if frame.intersects(visibleFrame) {
                continue
            }
            
            toRemove.append(tileIndex)
        }
        
        for index in toRemove {
            if index == selectedIndex {
                selectedTile = nil
            }
            
            let tile = tilesInUse.removeValue(forKey: index)!
            tile.run(TenPairHideTileAction)
            reusableTiles.append(tile)
        }
    }
    
    func ensureVisibleCovered(_ visible: CGRect, animated: Bool = false, completionAction: SKAction = SKAction.wait(forDuration: 0)) {
        let topY = size.height - (visible.origin.y + visible.size.height)
        let topLine = lineForY(topY)
        let startIndex = topLine * NumberOfColumns
        
        guard presentedNumbers.count > startIndex else {
            return
        }
        
        for index in startIndex..<presentedNumbers.count {
            let tileFrame = probeTileForIndex(index, animated:animated)
            let tileTop = tileFrame.origin.y + tileFrame.size.height
            if tileTop < visible.origin.y {
                break
            }
        }
        
        let waitAction = SKAction.wait(forDuration: TenPairRowHideTime + 0.1)
        let sequence = SKAction.sequence([waitAction, completionAction])
        run(sequence)
    }
    
    func probeTileForIndex(_ index: Int, animated: Bool) -> CGRect {
        let column = CGFloat(index % NumberOfColumns)
        let row = CGFloat(index / NumberOfColumns)
        let position = CGPoint(x: column * tileSize.width, y: size.height - tileSize.height - row * tileSize.height)
        var tile: TenPairNumberTile
        let number = presentedNumbers[index]

        var frame = CGRect.zero
        frame.origin = position
        frame.size = tileSize
        var tileCreated = false
        
        if number == 0 {
            if let tileAtProbe = tilesInUse[index] {
                tileAtProbe.run(TenPairHideTileAction)
                tilesInUse.removeValue(forKey: index)
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
                reused.run(TenPairUnhideTileAction)
            } else {
                sprite = TenPairNumberTile()
                addChild(sprite)
            }
            
            sprite.anchorPoint = CGPoint.zero
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
            let moveAction = SKAction.move(to: position, duration: TenPairRowHideTime)
            tile.run(moveAction)
        } else {
            tile.position = position
        }
        
        return frame
    }
    
    func lineForY(_ positionY: CGFloat) -> Int {
        return Int(positionY / tileSize.height)
    }
    
    func notifySizeChanged() {
        let lines = numberOfLines()
        
        let heigth = max(size.height, fieldHeight())
        
        size = CGSize(width: CGFloat(NumberOfColumns) * tileSize.width, height: heigth)
        
        background.update(size, numberOfLines: lines, numberOfTiles: presentedNumbers.count)
        
        scrollView?.contentSizeChanged()
    }
    
    func restartGame() {
        selectedTile = nil
        selectedIndex = -1
        lastHandledVisible = CGRect.zero
        for (_, value) in tilesInUse {
            let tile = value as TenPairNumberTile
            tile.run(TenPairHideTileAction)
            reusableTiles.append(tile)
        }
        tilesInUse.removeAll(keepingCapacity: true)
        updateFieldStatus()
        notifySizeChanged()
    }
    
    func fieldHeight () -> CGFloat {
        return CGFloat(numberOfLines()) * tileSize.height
    }
    
    func bottomOffset() -> CGFloat {
        return size.height - fieldHeight()
    }
    
    #if os(iOS)
    override func presentationInsets() -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, -bottomOffset(), 0)
    }
    #else
    override func presentationInsets() -> NSEdgeInsets {
        return NSEdgeInsetsMake(0, 0, -bottomOffset(), 0)
    }
    #endif
    
    func dumpRange(_ start: Int, end: Int) {
        for index in start...end {
            if index % NumberOfColumns == 0 {
                print("")
            }

            if index >= presentedNumbers.count {
                return
            }
            
            let number = presentedNumbers[index]
            print("\(number) ", terminator: "")
        }
    }
    
    func startOfLineForIndex(_ index: Int) -> Int {
        return index - index % NumberOfColumns
    }
    
    func endOfLineForIndex(_ index: Int) -> Int {
        return index + (NumberOfColumns - index % NumberOfColumns)
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

enum SearchResult {
    case foundOnScreen
    case foundOffScreen(CGFloat)
    case notFound
}

extension TenPairNumbersField: MatchFinder {
    func searchForMatch(_ completion: @escaping (SearchResult) -> ()) {
        Log.debug("Search match")
        inBackground() {
            let index = self.openMatchIndex(self.presentedNumbers)
            onMainThread() {
                Log.debug("Match index: \(index)")
                if let value = index {
                    self.selectedTile?.markUnselected()
                    
                    self.selectedIndex = value
                    if let tile = self.tilesInUse[value] {
                        Log.debug("Proposed on screen")
                        tile.markSelected()
                        self.selectedTile = tile
                        completion(.foundOnScreen)
                    } else {
                        let row = CGFloat(value / NumberOfColumns)
                        let proposedOffset = row * self.tileSize.height
                        completion(.foundOffScreen(proposedOffset))
                    }
                } else {
                    completion(.notFound)
                }
            }
        }
    }
}
