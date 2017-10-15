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

import CoreData

open class FetchedCollectionSection: NSObject, CollectionSection, SectionConfigured {
    public var cellConfigure: ((UICollectionViewCell, IndexPath, Bool) -> ())!
    public let cellIdentifier = UUID().uuidString
    private let controller: NSFetchedResultsController<NSManagedObject>
    public var itemsCount: Int {
        return controller.fetchedObjects?.count ?? 0
    }
    public let cellNib: UINib
    public let id: UUID
    internal lazy var measuringCell: UICollectionViewCell = {
        return self.cellNib.loadInstance() as! UICollectionViewCell
    }()
    internal weak var updatesDelegate: FetchedUpdatesDelegate?
    
    public init<Model: NSManagedObject, Cell: UICollectionViewCell>(id: UUID = UUID(), cell: Cell.Type, fetchedController: NSFetchedResultsController<Model>, configure: @escaping ((Cell, Model, Bool) -> ())) {
        self.id = id
        self.cellNib = cell.viewNib()
        controller = fetchedController as! NSFetchedResultsController<NSManagedObject>
        
        super.init()
        
        controller.delegate = self
        
        cellConfigure = {
            cell, indexPath, measuring in
            
            let model = fetchedController.object(at: indexPath)
            configure(cell as! Cell, model, measuring)
        }
    }
    
    open func size(in collectionView: UICollectionView, at indexPath: IndexPath) -> CGSize {
        return measuringCell.frame.size
    }
    
    public func object(at indexPath: IndexPath) -> NSManagedObject {
        return controller.object(at: indexPath)
    }
}

extension FetchedCollectionSection: NSFetchedResultsControllerDelegate {
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updatesDelegate?.beginUpdates()
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updatesDelegate?.endUpdates()
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        updatesDelegate?.section(self, changeAt: indexPath, for: type, newIndexPath: newIndexPath)
    }
}
