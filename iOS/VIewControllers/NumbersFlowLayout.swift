/*
* Copyright 2020 Coodly LLC
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

import UIKit

private let Columns = 9
private let ColumnsF = CGFloat(Columns)

internal class NumbersFlowLayout: UICollectionViewLayout {
    private var itemSize = CGSize(width: 50, height: 50)
    private var sectionInset = UIEdgeInsets.zero
    
    override func prepare() {
        super.prepare()
        
        let width = min((min(collectionView!.frame.width, collectionView!.frame.height) / ColumnsF).rounded(.down), 50)
        itemSize = CGSize(width: width, height: width)
        
        let inset = ((collectionView!.frame.width - width * ColumnsF) / 2).rounded(.down)
        sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
    
    override var collectionViewContentSize: CGSize {
        let tiles = collectionView!.numberOfItems(inSection: 0)
        let lines = (CGFloat(tiles) / ColumnsF).rounded(.up)
        
        return CGSize(width: collectionView!.frame.width, height: sectionInset.top + sectionInset.bottom + lines * itemSize.height)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return !newBounds.size.equalTo(collectionView.bounds.size)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        let line = CGFloat(indexPath.row / Columns)
        let column = CGFloat(indexPath.row % Columns)
        let origin = CGPoint(x: sectionInset.left + itemSize.width * column, y: sectionInset.top + line * itemSize.height)
        attributes.frame = CGRect(origin: origin, size: itemSize)
        return attributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let numberOfTiles = collectionView!.numberOfItems(inSection: 0)
        
        var result = [UICollectionViewLayoutAttributes]()
        
        var checkedY = rect.minY
        while checkedY < rect.maxY {
            defer {
                checkedY += itemSize.height
            }
            
            guard checkedY > 0 else {
                continue
            }
            
            let line = Int(checkedY / itemSize.height)
            for column in 0..<Columns {
                let index = line * Columns + column

                guard index < numberOfTiles else {
                    break
                }

                let indexPath = IndexPath(row: index, section: 0)
                result.append(layoutAttributesForItem(at: indexPath)!)
            }
        }
        
        return result
    }
}
