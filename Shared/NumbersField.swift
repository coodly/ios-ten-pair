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

import SpriteKit
import SpriteKitUI

private let SidesSpacing: CGFloat = 10 * 2
private let TenPairRowHideTime: TimeInterval = 0.3
private let TenPairHideTileAction = SKAction.hide()
private let TenPairUnhideTileAction = SKAction.unhide()
private let TenPairRemoveTileAction = SKAction.removeFromParent()

private extension Selector {
    static let save = #selector(NumbersField.save)
}

class NumbersField: ScrollViewContained {
    var ads: AdsCoordinator?
    
    override var withTaphHandler: Bool {
        return true
    }
    
    var presentedNumbers: [Int] = []
    
    var tileSize = CGSize.zero {
        didSet {
            ads?.tileSize = tileSize
            background.tileSize = tileSize
            background.lastHandledTopLine = -1
        }
    }
    
    private var tileColors = ColorSet()
    
    var gameWonAction: SKAction?
    
    var statusView: FieldStatusView?
    
    private lazy var background: FieldBackground = {
        let background = FieldBackground()
        self.addChild(background)
        return background
    }()
    
    override var presentationWidth: CGFloat {
        didSet {
            if oldValue == presentationWidth {
                return
            }
            
            let tileWidth = (presentationWidth - SidesSpacing) / CGFloat(NumberOfColumns)
            let maxWidth = CGFloat(AppConfig.current.maxTileWidth)
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
    
    private var lastHandledVisible = CGRect.zero
    fileprivate var tilesInUse = [Int: Tile]()
    fileprivate var selectedIndex: Int = -1
    fileprivate var selectedTile: Tile?
    private var reusableTiles = [Tile]()
    
    override func load() {
        NotificationCenter.default.addObserver(self, selector: .save, name: .saveField, object: nil)
    }
    
    @objc fileprivate func save() {
        Log.debug("Save")
        FieldSave.save(presentedNumbers)
    }
    
    func restart() {
        selectedTile = nil
        selectedIndex = -1
        lastHandledVisible = CGRect.zero
        for (_, tile) in tilesInUse {
            tile.run(TenPairHideTileAction)
            reusableTiles.append(tile)
        }
        tilesInUse.removeAll(keepingCapacity: true)
        updateFieldStatus()
        notifySizeChanged()
        
        save()
    }
    
    override func scrolledVisible(to visibleFrame: CGRect) {
        guard !tileSize.equalTo(.zero) else {
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
        
        ads?.scrolled(to: visibleFrame)
    }
    
    private func lineForY(_ positionY: CGFloat) -> Int {
        return Int(positionY / tileSize.height)
    }
    
    private func ensureVisibleCovered(_ visible: CGRect, animated: Bool = false, completionAction: SKAction = SKAction.wait(forDuration: 0)) {
        defer {
            let waitAction = SKAction.wait(forDuration: TenPairRowHideTime + 0.1)
            let sequence = SKAction.sequence([waitAction, completionAction])
            run(sequence)
        }
        
        let topY = size.height - (visible.origin.y + visible.size.height)
        let topLineWithAds = lineForY(topY)
        let topLine = ads?.removeAdLines(topLineWithAds) ?? topLineWithAds
        let startIndex = topLine * NumberOfColumns
        
        guard presentedNumbers.count > startIndex else {
            return
        }
        
        for index in startIndex..<presentedNumbers.count {
            let tileFrame = probeTileFor(index: index, animated:animated)
            let tileTop = tileFrame.origin.y + tileFrame.size.height
            if tileTop < visible.origin.y {
                break
            }
        }
    }
    
    private  func removeHiddenTiles(_ visibleFrame: CGRect) {
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
            
            guard let tile = tilesInUse.removeValue(forKey: index) else {
                continue
            }
            tile.run(TenPairHideTileAction)
            reusableTiles.append(tile)
        }
    }
    
    private func probeTileFor(index: Int, animated: Bool) -> CGRect {
        let column = CGFloat(index % NumberOfColumns)
        let row = CGFloat(index / NumberOfColumns)
        let yOffset = CGFloat(ads?.offsetFor(index: index) ?? 0)
        let position = CGPoint(x: column * tileSize.width, y: size.height - tileSize.height - row * tileSize.height - yOffset)
        var tile: Tile
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
            var sprite: Tile
            if let reused = reusableTiles.last {
                reusableTiles.removeLast()
                sprite = reused
                reused.run(TenPairUnhideTileAction)
            } else {
                sprite = Tile()
                sprite.colors = tileColors
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
    
    private func notifySizeChanged() {
        let presentationHeight = fieldHeight()
        let heigth = max(size.height, presentationHeight)
        size = CGSize(width: CGFloat(NumberOfColumns) * tileSize.width, height: heigth)
        let lines = numberOfLines()
        let adLines = ads?.adLines(for: lines) ?? 0
        background.update(size, numberOfLines: lines, adLines: adLines, numberOfTiles: presentedNumbers.count)
        scrollView?.contentSizeChanged(to: size, presentationHeight: presentationHeight)
    }

    private func numberOfLines() -> Int {
        return Int(ceilf(Float(presentedNumbers.count) / Float(NumberOfColumns)))
    }
    
    private func fieldHeight() -> CGFloat {
        let lines = numberOfLines()
        let tilesHight = CGFloat(lines) * tileSize.height
        let adsHeight = CGFloat(ads?.combinedHeight(with: lines) ?? 0)
        return tilesHight + adsHeight
    }
    
    private func bottomOffset() -> CGFloat {
        return size.height - fieldHeight()
    }
    
    override func presentationInsets() -> EdgeInsets {
        return EdgeInsetsMake(0, 0, -bottomOffset(), 0)
    }
    
    func reload() {
        let filtered = presentedNumbers.filter({ $0 != 0})
        presentedNumbers += filtered
        lastHandledVisible = .zero
        background.lastHandledTopLine = -1
        statusView?.set(tiles: filtered.count * 2)
        updateStatusLines()
        notifySizeChanged()
        
        save()
    }
    
    private func updateStatusLines() {
        let lines = numberOfLines()
        statusView?.set(lines: lines)
        ads?.totalLines = lines
    }
    
    override func handleTap(at point: CGPoint) {
        let checked = nodes(at: point)
        guard let tile = tileInArray(checked, tappedAt: point) else {
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
        
        acceptTouches = false
        
        tile.markSelected()
        
        let indexOne = selectedIndex
        let indexTwo = tileIndex
        
        guard NumbersPathFinder.hasClearPath([indexOne, indexTwo], inField: presentedNumbers) else {
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
    
    private func executeConsumeWithTiles(_ one: Tile?, two: Tile, atIndexOne: Int, atIndexTwo: Int) {
        let consumeActions = [
            SKAction.colorize(with: tileColors.successColor, colorBlendFactor: 1, duration: 0.3),
            SKAction.run(SKAction.hide(), onChildWithName: "numberLabel"),
            SKAction.colorize(with: tileColors.consumedColor, colorBlendFactor: 1, duration: 0.3),
        ]
        
        if let consumedOne = one {
            let zeroOneAction = SKAction.run({ () -> Void in
                consumedOne.number = 0
            })
            
            var firstActions = Array(consumeActions)
            firstActions.append(zeroOneAction)
            
            let firstSequence = SKAction.sequence(firstActions)
            
            consumedOne.backgroundNode.run(firstSequence)
        }
        
        let zeroTwoAndCompleteAction = SKAction.run() {
            self.statusView?.add(tiles: -2)

            two.number = 0
            self.selectedTile = nil
            self.selectedIndex = -1
            self.presentedNumbers[atIndexOne] = 0
            self.presentedNumbers[atIndexTwo] = 0
            let lines = EmptyLinesSearch.emptyRangesWithCheckPoints([atIndexOne, atIndexTwo], field: self.presentedNumbers)
            guard lines.count == 0 else {
                self.executeRemovingLines(lines)
                return
            }
            
            self.acceptTouches = true
            if self.gameCompleted() {
                self.run(self.gameWonAction!)
            }
        }
        
        var secondActions = Array(consumeActions)
        secondActions.append(zeroTwoAndCompleteAction)
        
        let secondSequence = SKAction.sequence(secondActions)
        
        two.backgroundNode.run(secondSequence)
    }
    
    private func executeRemovingLines(_ removed: [CountableRange<Int>]) {
        let lines = removed.sorted(by: { $0.lowerBound > $1.lowerBound })
        for removed in lines {
            presentedNumbers.removeSubrange(removed)
            for index in removed {
                if let tile = tilesInUse.removeValue(forKey: index) {
                    tile.run(TenPairRemoveTileAction)
                }
            }
            
            reindexTilesStaringFrom(removed.upperBound)
        }
        
        statusView?.add(lines: -lines.count)
        ads?.totalLines = numberOfLines()
        
        let lastHandled = lastHandledVisible
        lastHandledVisible = CGRect.zero
        
        let action = SKAction.run {
            self.acceptTouches = true
            self.notifySizeChanged()
            if self.gameCompleted() {
                self.run(self.gameWonAction!)
            }
        }
        
        ensureVisibleCovered(lastHandled, animated: true, completionAction: action)
    }
    
    func updateFieldStatus() {
        updateStatusLines()
        updateStatusTiles()
    }
    
    private func updateStatusTiles() {
        let nonZero = presentedNumbers.filter({ $0 != 0})
        statusView?.set(tiles: nonZero.count)
    }
    
    fileprivate func gameCompleted() -> Bool {
        if numberOfLines() > 1 {
            return false
        }
        
        return presentedNumbers.filter({ $0 != 0}).count == 0
    }
    
    private func reindexTilesStaringFrom(_ reindexStart: Int) {
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
    
    private func executeFailureAnimationWithTiles(_ one: Tile?, two: Tile) {
        let shakeActions = [
            SKAction.colorize(with: tileColors.failureColor, colorBlendFactor: 1, duration: 0.3),
            SKAction.move(by: CGVector(dx: 2, dy: 0), duration: 0.1),
            SKAction.move(by: CGVector(dx: -4, dy: 0), duration: 0.1),
            SKAction.move(by: CGVector(dx: 2, dy: 0), duration: 0.1),
            SKAction.colorize(with: tileColors.tileColor, colorBlendFactor: 1, duration: 0.3),
        ]
        
        if let animatedOne = one {
            let unmarkFirstAction = SKAction.run { () -> Void in
                animatedOne.markUnselected()
            }
            
            var firstActions = Array(shakeActions)
            firstActions.append(unmarkFirstAction)
            
            let firstSequence = SKAction.sequence(firstActions)
            
            animatedOne.backgroundNode.run(firstSequence)
        }
        
        let unmarkSecondAndResetSelectedAction = SKAction.run {
            two.markUnselected()
            self.selectedTile = nil
            self.selectedIndex = -1
            self.acceptTouches = true
        }
        
        var secondActions = Array(shakeActions)
        secondActions.append(unmarkSecondAndResetSelectedAction)
        
        let secondSequence = SKAction.sequence(secondActions)
        
        two.backgroundNode.run(secondSequence)
    }
    
    private func tileInArray(_ nodes: [AnyObject], tappedAt: CGPoint) -> Tile? {
        for node in Array(nodes.reversed()) {
            guard let tile = node as? Tile, !tile.isHidden else {
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

    private func indexOfNode(_ node: Tile) -> Int {
        for (index, tile) in tilesInUse {
            guard tile == node else {
                continue
            }
            
            return index
        }

        fatalError("Tile not in used ones")
    }
    
    override func set(color: SKColor, for attribute: Appearance.Attribute) {
        switch attribute {
        case Appearance.Attribute.tileNumber:
            tileColors.tileNumberColor = color
        case Appearance.Attribute.tile:
            tileColors.tileColor = color
        case Appearance.Attribute.selected:
            tileColors.selectedColor = color
        case Appearance.Attribute.success:
            tileColors.successColor = color
        case Appearance.Attribute.failure:
            tileColors.failureColor = color
        case Appearance.Attribute.numberFieldBackground:
            tileColors.consumedColor = color
            background.fillColor = color
        case Appearance.Attribute.background:
            background.lineColor = color
        default:
            break // no op
        }
        
        for (_, tile) in tilesInUse {
            tile.colors = tileColors
        }
        
        for tile in reusableTiles {
            tile.colors = tileColors
        }
    }
}

enum SearchResult {
    case foundOnScreen
    case foundOffScreen(CGFloat)
    case notFound
}

extension NumbersField: MatchFinder {
    func searchForMatch(_ completion: (SearchResult) -> ()) {
        Log.debug("Search match")
        let index = self.openMatchIndex(self.presentedNumbers)

        guard let value = index else {
            let shakeActions = [
                SKAction.move(by: CGVector(dx: 4, dy: 0), duration: 0.1),
                SKAction.move(by: CGVector(dx: -8, dy: 0), duration: 0.1),
                SKAction.move(by: CGVector(dx: 8, dy: 0), duration: 0.1),
                SKAction.move(by: CGVector(dx: -4, dy: 0), duration: 0.1),
            ]
            completion(.notFound)
            run(SKAction.sequence(shakeActions))
            return
        }
        
        Log.debug("Match index: \(value)")
        self.selectedTile?.markUnselected()
        
        self.selectedIndex = value
        if let tile = self.tilesInUse[value] {
            Log.debug("Proposed on screen")
            tile.markSelected()
            self.selectedTile = tile
            completion(.foundOnScreen)
        } else {
            let row = Int(value / NumberOfColumns)
            let adLines = ads?.adLines(for: row) ?? 0
            let proposedOffset = CGFloat(row + adLines) * self.tileSize.height
            completion(.foundOffScreen(proposedOffset))
        }
    }
}
