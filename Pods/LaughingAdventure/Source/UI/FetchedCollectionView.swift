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

open class FetchedCollectionView<Model: NSManagedObject, Cell: UICollectionViewCell>: UICollectionView, UICollectionViewDataSource, NSFetchedResultsControllerDelegate, UICollectionViewDelegate {
    public var fetchedController: NSFetchedResultsController<Model>? {
        didSet {
            registerCell(forType: Cell.self)
            fetchedController?.delegate = self
            dataSource = self
            delegate = self
        }
    }
    private var changeActions = [ChangeAction]()
    public var cellConfiguration: ((Cell, Model, IndexPath) -> ())?
    public var contentChangeHandler: ((FetchedCollectionView<Model, Cell>) -> ())?
    public var selectionHandler: ((Model, IndexPath) -> ())?

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedController?.sections?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let controller = fetchedController else {
            return 0
        }
        
        let sections:[NSFetchedResultsSectionInfo] = controller.sections! as [NSFetchedResultsSectionInfo]
        return sections[section].numberOfObjects
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as Cell
        let object = fetchedController!.object(at: indexPath)
        cellConfiguration?(cell, object, indexPath)
        return cell
    }
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        Logging.log("controllerWillChangeContent")
        changeActions.removeAll()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        changeActions.append(ChangeAction(sectionIndex: sectionIndex, indexPath: nil, newIndexPath: nil, changeType: type))
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        changeActions.append(ChangeAction(sectionIndex: nil, indexPath: indexPath, newIndexPath: newIndexPath, changeType: type))
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        Logging.log("controllerDidChangeContent: \(changeActions.count) changes")
        let visible = indexPathsForVisibleItems
        
        let updateClosure = {
            // update sections
            let sectionActions = self.changeActions.filter({ $0.sectionIndex != nil })
            Logging.log("\(sectionActions.count) section actions")
            
            let sectionInserts = sectionActions.filter({ $0.changeType == .insert }).map({ $0.sectionIndex! })
            self.insertSections(IndexSet(sectionInserts))
            
            let sectionDeletes = sectionActions.filter({ $0.changeType == .insert }).map({ $0.sectionIndex! })
            self.deleteSections(IndexSet(sectionDeletes))
            
            assert(sectionActions.filter({ $0.changeType != .insert && $0.changeType != .delete}).count == 0)
            
            let cellActions = self.changeActions.filter({ $0.sectionIndex == nil })
            Logging.log("\(cellActions.count) cell actions")
            
            let cellUpdates = cellActions.filter({ $0.changeType == .update })
            self.reloadItems(at: cellUpdates.map({ $0.indexPath! }))
            
            let cellInserts = cellActions.filter({ $0.changeType == .insert }).map({ $0.newIndexPath! })
            self.insertItems(at: cellInserts)
            
            let cellDeletes = cellActions.filter({ $0.changeType == .delete}).map({ $0.indexPath! })
            self.deleteItems(at: cellDeletes)
            
            let moveActions = cellActions.filter({ $0.changeType == .move})
            for action in moveActions {
                self.moveItem(at: action.indexPath!, to: action.newIndexPath!)
            }
        }
        
        let completion: (Bool) -> () = {
            finished in
            
            self.contentChangeHandler?(self)
        }
        
        performBatchUpdates(updateClosure, completion: completion)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            return
        }
    
        contentChangeHandler?(self)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        contentChangeHandler?(self)
    }
    
    public func object(at indexPath: IndexPath) -> Model {
        return fetchedController!.object(at: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let object = fetchedController!.object(at: indexPath)
        selectionHandler?(object, indexPath)
    }
}
