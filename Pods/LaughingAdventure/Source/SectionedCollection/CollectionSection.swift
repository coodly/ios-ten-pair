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

import UIKit

public protocol CollectionSection {
    var cellIdentifier: String { get }
    var itemsCount: Int { get }
    var cellNib: UINib { get }
    var id: UUID { get }
    
    func size(in collectionView: UICollectionView, at indexPath: IndexPath) -> CGSize
}

internal protocol SectionConfigured {
    var cellConfigure: ((UICollectionViewCell, IndexPath, Bool) -> ())! { get }
}
