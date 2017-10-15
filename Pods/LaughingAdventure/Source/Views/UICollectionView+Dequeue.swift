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

public extension UICollectionView {
    public func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: T.identifier(), for: indexPath) as! T
    }
    
    public func registerCell<T: UICollectionViewCell>(forType type: T.Type) {
        register(T.viewNib(Bundle(for: T.self)), forCellWithReuseIdentifier: T.identifier())
    }
}
