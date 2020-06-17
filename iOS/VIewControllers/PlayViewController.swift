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

internal class PlayViewController: UIViewController {
    private lazy var field = PlayField()
    
    @IBOutlet private var collectionView: UICollectionView!
    private var selected = Set<Int>()
    
    private lazy var reloadButton = UIBarButtonItem(title: "Reload", style: .plain, target: self, action: #selector(reloadField))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        field.load()
        
        navigationItem.rightBarButtonItem = reloadButton
        collectionView.registerCell(forType: NumberCell.self)
    }
    
    @objc fileprivate func reloadField() {
        field.reload()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        DispatchQueue.main.async {
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    private func reload(previous: Set<Int>, current: Set<Int>, animated: Bool) {
        let reloaded = previous.union(current)
        let indexPaths = reloaded.map({ IndexPath(row: $0, section: 0) })
        
        let animation: (() -> Void) = {
            self.collectionView.reloadItems(at: indexPaths)
        }
        
        if animated {
            animation()
        } else {
            UIView.performWithoutAnimation(animation)
        }
    }
}

extension PlayViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        field.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: NumberCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.show(number: field.number(at: indexPath.row), selected: selected.contains(indexPath.row))
        return cell
    }
}

extension PlayViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let original = selected
        if selected.contains(indexPath.row) {
            selected.remove(indexPath.row)
        } else {
            selected.insert(indexPath.row)
        }
        
        reload(previous: original, current: selected, animated: false)
    }
}
