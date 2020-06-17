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

private let Columns = CGFloat(9)

internal class NumbersFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        
        let width = min((min(collectionView!.frame.width, collectionView!.frame.height) / Columns).rounded(.down), 50)
        itemSize = CGSize(width: width, height: width)
        
        let inset = ((collectionView!.frame.width - width * Columns) / 2).rounded(.down)
        sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
}
