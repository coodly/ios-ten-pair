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
import GameKit

private let NumberOfColumns = 9
private let SidesSpacing: CGFloat = 10 * 2
private let TenPairRowHideTime: TimeInterval = 0.3
private let TenPairHideTileAction = SKAction.hide()
private let TenPairUnhideTileAction = SKAction.unhide()

class NumbersField: ScrollViewContained {
    var presentedNumbers: [Int] = []
    
    private var tileSize = CGSize.zero
    
    private var tileColors = ColorSet()
    
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
    private var tilesInUse = [Int: Tile]()
    private var selectedIndex: Int = -1
    private var selectedTile: Tile?
    private var reusableTiles = [Tile]()
    
    override func load() {
        color = .blue
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
        
        lastHandledVisible = visibleFrame
        ensureVisibleCovered(toCheck)
        removeHiddenTiles(visibleFrame)
    }
    
    private func lineForY(_ positionY: CGFloat) -> Int {
        return Int(positionY / tileSize.height)
    }
    
    private func ensureVisibleCovered(_ visible: CGRect, animated: Bool = false, completionAction: SKAction = SKAction.wait(forDuration: 0)) {
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
            
            let tile = tilesInUse.removeValue(forKey: index)!
            tile.run(TenPairHideTileAction)
            reusableTiles.append(tile)
        }
    }
    
    private func probeTileForIndex(_ index: Int, animated: Bool) -> CGRect {
        let column = CGFloat(index % NumberOfColumns)
        let row = CGFloat(index / NumberOfColumns)
        let position = CGPoint(x: column * tileSize.width, y: size.height - tileSize.height - row * tileSize.height)
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
                addChild(sprite)
            }
            
            sprite.colors = tileColors
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
        
        tile.colors = tileColors
        
        if animated && !tileCreated {
            let moveAction = SKAction.move(to: position, duration: TenPairRowHideTime)
            tile.run(moveAction)
        } else {
            tile.position = position
        }
        
        return frame
    }
    
    private func notifySizeChanged() {
        let lines = numberOfLines()
        
        let heigth = max(size.height, fieldHeight())
        
        size = CGSize(width: CGFloat(NumberOfColumns) * tileSize.width, height: heigth)
        
        scrollView?.contentSizeChanged()
    }

    private func numberOfLines() -> Int {
        return Int(ceilf(Float(presentedNumbers.count) / Float(NumberOfColumns)))
    }
    
    private func fieldHeight () -> CGFloat {
        return CGFloat(numberOfLines()) * tileSize.height
    }
    
    private func bottomOffset() -> CGFloat {
        return size.height - fieldHeight()
    }
    
    override func presentationInsets() -> EdgeInsets {
        return EdgeInsetsMake(0, 0, -bottomOffset(), 0)
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
        default:
            break // no op
        }
        
        for (_, tile) in tilesInUse {
            tile.colors = tileColors
        }
    }
}
