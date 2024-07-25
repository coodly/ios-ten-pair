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

extension UICollectionView {
  public func registerCell<T: UICollectionViewCell>(forType type: T.Type, from bundle: Bundle) {
    register(T.viewNib(bundle), forCellWithReuseIdentifier: T.className)
  }

  public func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
    return dequeueReusableCell(withReuseIdentifier: T.className, for: indexPath) as! T
  }

  internal func registerHeaderView<T: UICollectionReusableView>(forType type: T.Type) {
    register(T.viewNib(Bundle(for: T.self)), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.className)
  }

  internal func dequeueReusableHeader<T: UICollectionReusableView>(at indexPath: IndexPath) -> T {
    return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.className, for: indexPath) as! T
  }
}

