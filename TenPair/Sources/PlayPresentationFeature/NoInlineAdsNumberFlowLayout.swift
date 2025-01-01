/*
 * Copyright 2025 Coodly LLC
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

internal class NoInlineAdsNumberFlowLayout: UICollectionViewFlowLayout {
  let Columns = 9
  let ColumnsF = CGFloat(9)
  let Padding = CGFloat(8)
  let HintButtonTrayHeight = CGFloat(44 + 2 + 2)

  override func prepare() {
    let minDimension = min(collectionView!.frame.width, collectionView!.frame.height)
    let availableWidth = minDimension - Padding * 2
        
    let width = min((availableWidth / ColumnsF).rounded(.down), 50)
    itemSize = CGSize(width: width, height: width)
    
    let inset = ((collectionView!.frame.width - width * ColumnsF) / 2).rounded(.down)
    sectionInset = UIEdgeInsets(top: Padding, left: inset, bottom: Padding * 2 + HintButtonTrayHeight, right: inset)
    
    minimumLineSpacing = 0
    minimumInteritemSpacing = 0
  }
  
  override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    guard let collectionView = collectionView else { return false }
    return !newBounds.size.equalTo(collectionView.bounds.size)
  }
}
