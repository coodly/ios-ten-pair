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
import CoreGraphics

public struct LayoutPosition {
    private let showingAds: Bool
    private let adAfterLines: Int
    private let itemSize: CGSize
    private let adSize: CGSize
    public init(showingAds: Bool, adAfterLines: Int, itemSize: CGSize, adSize: CGSize) {
        self.showingAds = showingAds
        self.adAfterLines = adAfterLines
        self.itemSize = itemSize
        self.adSize = adSize
    }
    
    public func numberOfSections(with field: [Int]) -> Int {
        guard showingAds else {
            return 1
        }
        
        let tilesInSection = NumberOfColumns * adAfterLines
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
        let numberOfTilesInSection = NumberOfColumns * adAfterLines
        let fullSections = field.count / numberOfTilesInSection
        if tileSection < fullSections {
            return numberOfTilesInSection
        }
        
        return field.count % numberOfTilesInSection
    }
    
    public func contentHeight(using field: [Int]) -> CGFloat {
        guard showingAds else {
            return (CGFloat(field.count) / CGFloat(NumberOfColumns)).rounded(.up) * itemSize.height
        }
        
        let tilesInSection = NumberOfColumns * adAfterLines
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
}
