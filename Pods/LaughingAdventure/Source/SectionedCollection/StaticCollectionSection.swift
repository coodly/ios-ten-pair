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

public enum Measure: Equatable {
    case exactly(CGFloat)
    case full
    case compressed
    case undefined
}

public func ==(lhs: Measure, rhs: Measure) -> Bool  {
    switch (lhs, rhs) {
    case (.full, .full):
        return true
    case (.compressed, .compressed):
        return true
    case (.undefined, .undefined):
        return true
    default:
        return false
    }
}

public struct Size {
    public static let cellDefined = Size(width: .undefined, height: .undefined)
    
    public let width: Measure
    public let height: Measure
    
    public init(width: Measure, height: Measure) {
        self.width = width
        self.height = height
    }
}

open class StaticCollectionSection: CollectionSection, SectionConfigured {
    public var cellConfigure: ((UICollectionViewCell, IndexPath, Bool) -> ())!
    public let cellIdentifier = UUID().uuidString
    public let cellNib: UINib
    public let itemsCount: Int
    let itemSize: Size
    public let id: UUID
    private lazy var measuringCell: UICollectionViewCell = {
        return self.cellNib.loadInstance() as! UICollectionViewCell
    }()
    
    public init<Cell: UICollectionViewCell>(id: UUID = UUID(), cell: Cell.Type, numberOfItems: Int = 1, itemSize: Size, configure: @escaping ((Cell, IndexPath, Bool) -> ())) {
        self.id = id
        self.cellNib = cell.viewNib()
        self.itemsCount = numberOfItems
        self.itemSize = itemSize
        
        cellConfigure = {
            cell, indexPath, measuring in
            
            configure(cell as! Cell, indexPath, measuring)
        }
    }
    
    open func size(in collectionView: UICollectionView, at indexPath: IndexPath) -> CGSize {
        let size = itemSize
        
        if size.width == .undefined && size.height == .undefined {
            return measuringCell.frame.size
        }
        
        cellConfigure(measuringCell, indexPath, true)
        
        if size.width == .full && size.height == .compressed {
            measuringCell.frame.size.width = collectionView.frame.width
            measuringCell.setNeedsLayout()
            measuringCell.layoutIfNeeded()
            measuringCell.frame.size.height = measuringCell.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        }
        return measuringCell.frame.size
    }
}
