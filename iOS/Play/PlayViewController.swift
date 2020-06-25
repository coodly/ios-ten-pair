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
import GameplayKit

internal protocol PlayDelegate: class {
    func animateFailure()
    func animateSuccess()
    func clearSelection()
    func checkEmptyLines()
}

internal class PlayViewController: UIViewController {
    private lazy var field = PlayField()
    
    @IBOutlet private var collectionView: UICollectionView!
    private var selected = Set<Int>()
    
    private lazy var menuButton = UIBarButtonItem(image: Rendered.menuIcon(), style: .plain, target: self, action: #selector(presentMenu))
    private lazy var reloadButton = UIBarButtonItem(image: Rendered.reloadIcon(), style: .plain, target: self, action: #selector(reloadField))
    private lazy var machine = GKStateMachine(states: [
        SelectingNumber(delegate: self),
        AnimatingSuccess(delegate: self),
        AnimatingFailure(delegate: self),
        EmptyLinesCheck(delegate: self)
    ])
    @IBOutlet private var hintButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.collectionViewLayout = NumbersFlowLayout()
        collectionView.backgroundView = BackgroundView()    
        
        field.load()
        
        navigationItem.leftBarButtonItem = menuButton
        navigationItem.rightBarButtonItem = reloadButton
        collectionView.registerCell(forType: NumberCell.self)
        
        field.statusDelegate = navigationItem.titleView as! StatusLabel
        
        machine.enter(SelectingNumber.self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(saveField), name: UIApplication.willResignActiveNotification, object: nil)
        
        hintButton.setImage(Rendered.hintIcon(), for: .normal)
    }
    
    @objc fileprivate func reloadField() {
        guard machine.currentState is SelectingNumber else {
            return
        }
        
        field.reload()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    @objc fileprivate func saveField() {
        field.save()
    }
    
    @IBAction func giveAHint() {
        guard let hintIndex = field.openMatch() else {
            return
        }
        
        let original = selected
        selected.removeAll()
        selected.insert(hintIndex)
        let index = IndexPath(row: hintIndex, section: 0)
        if collectionView.indexPathsForVisibleItems.contains(index) {
            reload(previous: original, current: selected, animated: false)
        }
        collectionView.scrollToItem(at: index, at: .centeredVertically, animated: true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        DispatchQueue.main.async {
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    private func reload(indexes: Set<Int>, completion: ((Bool) -> Void)? = nil) {
        reload(previous: indexes, current: indexes, animated: true, completion: completion)
    }
    
    private func reload(previous: Set<Int>, current: Set<Int>, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        let reloaded = previous.union(current)
        let indexPaths = reloaded.map({ IndexPath(row: $0, section: 0) })
        
        let animation: (() -> Void) = {
            let updates: (() -> Void) = {
                self.collectionView.reloadItems(at: indexPaths)
            }
            self.collectionView.performBatchUpdates(updates, completion: completion)
        }
        
        if animated {
            animation()
        } else {
            UIView.performWithoutAnimation(animation)
        }
    }
    
    private func checkForMatch() {
        guard selected.count > 1 else {
            return
        }
        
        let array = Array(selected)
        guard let first = array.first, let second = array.last else {
            return
        }
        
        let action = field.match(first: first, second: second)
        switch action {
        case .failure:
            machine.enter(AnimatingFailure.self)
        case .match:
            machine.enter(AnimatingSuccess.self)
        }
    }
    
    @objc fileprivate func presentMenu() {
        let menu: MenuViewController = Storyboards.loadFromStoryboard()
        menu.delegate = self
        
        let navigation = PlayNavigationController(rootViewController: menu)
        navigation.isNavigationBarHidden = true
        navigation.view.backgroundColor = .clear
        navigation.modalPresentationStyle = .custom
        
        present(navigation, animated: false)
    }
}

extension PlayViewController: PlayDelegate {
    func animateSuccess() {
        reload(indexes: selected) {
            _ in
            
            self.field.clear(numbers: self.selected)
            self.machine.enter(EmptyLinesCheck.self)
        }
    }
    
    func animateFailure() {
        reload(indexes: selected) {
            _ in
            
            self.machine.enter(SelectingNumber.self)
        }
    }
    
    func clearSelection() {
        guard selected.count > 0 else {
            return
        }
        
        let animated = selected
        selected.removeAll()
        reload(indexes: animated)
    }
    
    func checkEmptyLines() {
        let animated = selected
        selected.removeAll()
        reload(indexes: animated) {
            _ in
            
            self.removeEmptyLines(checked: animated)
        }
    }
    
    private func removeEmptyLines(checked: Set<Int>) {
        let empty = field.emptyLines(with: checked)
        guard empty.count > 0 else {
            machine.enter(SelectingNumber.self)
            return
        }
        
        field.remove(lines: empty)
        let removed = empty.map({ Array($0.lowerBound..<$0.upperBound) }).flatMap({ $0 }).map({ IndexPath(row: $0, section: 0) })
        let update: (() -> Void) = {
            self.collectionView.deleteItems(at: removed)
        }
        collectionView.performBatchUpdates(update) {
            _ in
            
            self.machine.enter(SelectingNumber.self)
        }
    }
}

extension PlayViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        field.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: NumberCell = collectionView.dequeueReusableCell(for: indexPath)
        let marker: NumberMarker
        if selected.contains(indexPath.row) {
            marker = NumberMarker.from(state: machine.currentState as? PlayState)
        } else {
            marker = .standard
        }
        cell.show(number: field.number(at: indexPath.row), marker: marker)
        return cell
    }
}

extension PlayViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard machine.currentState is SelectingNumber else {
            return false
        }
        
        return field.hasValue(at: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let original = selected
        if selected.contains(indexPath.row) {
            selected.remove(indexPath.row)
        } else {
            selected.insert(indexPath.row)
        }
        
        reload(previous: original, current: selected, animated: false) {
            _ in
            
            self.checkForMatch()
        }
    }
}

extension PlayViewController: MenuDelegate {
    func tapped(option: MenuOption) {
        dismiss(animated: false)
        
        switch option {
        case .restart(let lines):
            collectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 10, height: 10), animated: false)
            field.restart(with: lines)
            collectionView.reloadData()
        default:
            Log.debug("Unhandled \(option)")
        }
    }
}
