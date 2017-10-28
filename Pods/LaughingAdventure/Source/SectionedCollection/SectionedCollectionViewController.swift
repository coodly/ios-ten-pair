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

import Foundation
import UIKit
import CoreData

open class SectionedCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet public var collectionView: UICollectionView!
    
    fileprivate var sections = [CollectionSection]()
    fileprivate var changeActions = [ChangeAction]()

    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if collectionView == nil {
            //not loaded from xib
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.backgroundColor = UIColor.clear
            view.addSubview(collectionView)
            
            let views: [String: AnyObject] = ["collection": collectionView]
            
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            let vertical = NSLayoutConstraint.constraints(withVisualFormat: "V:|[collection]|", options: [], metrics: nil, views: views)
            let horizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|[collection]|", options: [], metrics: nil, views: views)
            
            view.addConstraints(vertical + horizontal)
        }
    }
    
    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let dataSection = sections[section]
        return dataSection.itemsCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = sections[indexPath.section]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: section.cellIdentifier, for: indexPath)
        let path = IndexPath(row: indexPath.row, section: 0)
        if let configured = section as? SectionConfigured {
            configured.cellConfigure(cell, path, false)
        }
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let section = sections[indexPath.section]
        let indexPathInSection = IndexPath(row: indexPath.row, section: 0)
        return section.size(in: collectionView, at: indexPathInSection)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let section = sections[indexPath.section]
        let indexPathInSection = IndexPath(row: indexPath.row, section: 0)
        tappedCell(in: section, at: indexPathInSection)
    }

    public func append(section: CollectionSection) {
        let collection = collectionView!
        let updates = {
            let insertAt = self.sections.count
            collection.register(section.cellNib, forCellWithReuseIdentifier: section.cellIdentifier)
            self.sections.append(section)
            
            if let fetched = section as? FetchedCollectionSection {
                fetched.updatesDelegate = self
            }
            
            collection.insertSections(IndexSet(integer: insertAt))
        }
        collection.performBatchUpdates(updates)
    }
    
    public func reload(_ sectionId: UUID) {
        guard let index = sections.index(where: { $0.id == sectionId }) else {
            return
        }
        
        let collection = collectionView!
        let updates = {
            collection.reloadSections(IndexSet(integer: index))
        }
        collection.performBatchUpdates(updates)
    }

    open func tappedCell(in section: CollectionSection, at indexPath: IndexPath) {
        Logging.log("tappedCell(at:\(indexPath))")
    }
}

extension SectionedCollectionViewController: FetchedUpdatesDelegate {
    func beginUpdates() {
        changeActions.removeAll()
    }
    
    func section(_ section: FetchedCollectionSection, changeAt indexPath: IndexPath?, for changeType: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let sectionIndex = sections.index(where: { $0.id == section.id }) else {
            return
        }
        
        let original: IndexPath?
        let target: IndexPath?
        if let index = indexPath {
            original = IndexPath(row: index.row, section: sectionIndex)
        } else {
            original = nil
        }
        if let index = newIndexPath {
            target = IndexPath(row: index.row, section: sectionIndex)
        } else {
            target = nil
        }
        
        changeActions.append(ChangeAction(sectionIndex: nil, indexPath: original, newIndexPath: target, changeType: changeType))
    }
    
    func endUpdates() {
        // TODO jaanus: copy/paste |-(
        let updateClosure = {
            // update sections
            let sectionActions = self.changeActions.filter({ $0.sectionIndex != nil })
            Logging.log("\(sectionActions.count) section actions")
            
            let sectionInserts = sectionActions.filter({ $0.changeType == .insert }).map({ $0.sectionIndex! })
            self.collectionView.insertSections(IndexSet(sectionInserts))
            
            let sectionDeletes = sectionActions.filter({ $0.changeType == .insert }).map({ $0.sectionIndex! })
            self.collectionView.deleteSections(IndexSet(sectionDeletes))
            
            assert(sectionActions.filter({ $0.changeType != .insert && $0.changeType != .delete}).count == 0)
            
            let cellActions = self.changeActions.filter({ $0.sectionIndex == nil })
            Logging.log("\(cellActions.count) cell actions")
            
            let cellUpdates = cellActions.filter({ $0.changeType == .update })
            self.collectionView.reloadItems(at: cellUpdates.map({ $0.indexPath! }))
            
            let cellInserts = cellActions.filter({ $0.changeType == .insert }).map({ $0.newIndexPath! })
            self.collectionView.insertItems(at: cellInserts)
            
            let cellDeletes = cellActions.filter({ $0.changeType == .delete}).map({ $0.indexPath! })
            self.collectionView.deleteItems(at: cellDeletes)
            
            let moveActions = cellActions.filter({ $0.changeType == .move})
            for action in moveActions {
                self.collectionView.moveItem(at: action.indexPath!, to: action.newIndexPath!)
            }
        }
        
        let completion: (Bool) -> () = {
            finished in
            
            
        }
        
        collectionView.performBatchUpdates(updateClosure, completion: completion)
    }
}
