/*
* Copyright 2021 Coodly LLC
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

import Config
import UIKit

public struct LayoutPosition {
    private let showingAds: Bool
    private let adAfterLines: Int
    private let itemSize: CGSize
    private let adSize: CGSize
    private let tilesInSection: Int
    private let tilesSectionHeight: CGFloat
    public init(showingAds: Bool, adAfterLines: Int, itemSize: CGSize, adSize: CGSize) {
        self.showingAds = showingAds
        self.adAfterLines = adAfterLines
        self.itemSize = itemSize
        self.adSize = adSize
        
        tilesInSection = NumberOfColumns * adAfterLines
        tilesSectionHeight = CGFloat(adAfterLines) * itemSize.height
    }
    
    public func numberOfSections(with field: [Int]) -> Int {
        guard showingAds else {
            return 1
        }
        
        let fullTilesSections = field.count / tilesInSection
        let partial = field.count % tilesInSection != 0
        return fullTilesSections + fullTilesSections + (partial ? 1 : 0)
    }
    
    public func numberOfRows(in section: Int, using field: [Int]) -> Int {
        guard showingAds else {
            return field.count
        }
        
        if section % 2 == 1 {
            return 1
        }
        
        let tileSection = section / 2
        let fullSections = field.count / tilesInSection
        if tileSection < fullSections {
            return tilesInSection
        }
        
        return field.count % tilesInSection
    }
    
    public func contentHeight(using field: [Int]) -> CGFloat {
        guard showingAds else {
            return (CGFloat(field.count) / CGFloat(NumberOfColumns)).rounded(.up) * itemSize.height
        }
        
        let fullTilesSections = field.count / tilesInSection
        let tilesInPartial = field.count % tilesInSection
        let linesInPartial = (CGFloat(tilesInPartial) / CGFloat(NumberOfColumns)).rounded(.up)

        return CGFloat(adAfterLines * fullTilesSections) * itemSize.height + CGFloat(fullTilesSections) * adSize.height + linesInPartial * itemSize.height
    }
    
    public func contentHeight(with sections: Int, itemsInLast: Int) -> CGFloat {
        guard showingAds else {
            return (CGFloat(itemsInLast) / CGFloat(NumberOfColumns)).rounded(.up) * itemSize.height
        }

        let row = itemsInLast - 1
        let section = sections - 1
        let lastCellPosition = position(of: row, in: section)
        let lastCellHeight = section % 2 == 1 ? adSize.height : itemSize.height
        return lastCellPosition.y + lastCellHeight
    }
    
    public func position(of row: Int, in section: Int) -> CGPoint {
        guard showingAds else {
            let line = CGFloat(row / NumberOfColumns)
            let column = CGFloat(row % NumberOfColumns)
            return CGPoint(x: itemSize.width * column, y: itemSize.height * line)
        }

        let tilesSectionHeight = itemSize.height * CGFloat(adAfterLines)
        let adSectionHeight = adSize.height

        var sectionOffset: CGFloat = 0
        
        for index in 0..<section {
            if index % 2 == 1 {
                sectionOffset += adSectionHeight
            } else {
                sectionOffset += tilesSectionHeight
            }
        }
        
        let line = CGFloat(row / NumberOfColumns)
        let column = CGFloat(row % NumberOfColumns)

        return CGPoint(x: itemSize.width * column, y: itemSize.height * line + sectionOffset)
    }
    
    public func indexPaths(covering frame: CGRect, max: IndexPath) -> [IndexPath] {
        showingAds ? indexPathsWithAds(from: frame, max: max) : indexPathsWithoutAds(from: frame, max: max)
    }
    
    private func indexPathsWithoutAds(from frame: CGRect, max: IndexPath) -> [IndexPath] {
        var result = [IndexPath]()
        var offsetY = Swift.max(frame.minY, 0)
        let columns = 0...8
        repeat {
            let line = Int(offsetY / itemSize.height)
            for column in columns {
                let index = line * NumberOfColumns + column
                                
                let indexPath = IndexPath(row: index, section: 0)
                if indexPath <= max {
                    result.append(indexPath)
                }
            }

            offsetY += itemSize.height
        } while offsetY < frame.maxY
        
        return result
    }

    private func indexPathsWithAds(from frame: CGRect, max: IndexPath) -> [IndexPath] {
        var result = [IndexPath]()
        
        var offsetY = Swift.max(frame.origin.y, 0)
        var section = self.section(from: offsetY)
        
        while offsetY <= (frame.origin.y + frame.height) {
            if section % 2 == 1 {
                result.append(IndexPath(row: 0, section: section))
                offsetY += adSize.height
            } else {
                let rows = 0..<(NumberOfColumns * AdAfterLines)
                result.append(contentsOf: rows.map({ IndexPath(row: $0, section: section) }))
                offsetY += tilesSectionHeight
            }
            
            section += 1
        }
        
        return result.filter({ $0 <= max })
    }
    
    private func section(from y: CGFloat) -> Int {
        var offset = y
        var section = 0
        
        while offset > 0 {
            if section % 2 == 1 {
                offset -= adSize.height
            } else {
                offset -= tilesSectionHeight
            }
            
            if offset > 0 {
                section += 1
            }
        }
        
        return section
    }
}
