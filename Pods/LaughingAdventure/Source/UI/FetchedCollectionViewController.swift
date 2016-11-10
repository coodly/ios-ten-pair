/*
* Copyright 2015 Coodly LLC
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

private extension Selector {
    static let contentSizeChanged = #selector(FetchedCollectionViewController.contentSizeChanged)
}

class CollectionCoreDataChangeAction {
    var indexPath: IndexPath?
    var newIndexPath: IndexPath?
    var changeType = NSFetchedResultsChangeType.update
    
    static func action(_ atIndexPath: IndexPath?, changeType: NSFetchedResultsChangeType, newIndexPath: IndexPath?) -> CollectionCoreDataChangeAction {
        let result = CollectionCoreDataChangeAction()
        result.indexPath = atIndexPath
        result.changeType = changeType
        result.newIndexPath = newIndexPath
        return result
    }
}

let FetchedCollectionCellIdentifier = "FetchedCollectionCellIdentifier"

open class FetchedCollectionViewController<Model: NSManagedObject, Cell: UICollectionViewCell>: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    
    @IBOutlet public var collectionView: UICollectionView!
    private var fetchedController: NSFetchedResultsController<Model>?
    private var measuringCell: Cell?
    private var changeActions: [CollectionCoreDataChangeAction]!
    
    public var ignoreOffScreenUpdates = false
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    open override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: .contentSizeChanged, name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        
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

        let cellNib = Cell.viewNib()
        collectionView.register(cellNib, forCellWithReuseIdentifier: FetchedCollectionCellIdentifier)
        measuringCell = cellNib.loadInstance() as! Cell
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if fetchedController != nil {
            return
        }
        
        fetchedController = createFetchedController()
        fetchedController!.delegate = self
        
        collectionView.reloadData()
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let controller = fetchedController else {
            return 0
        }
        
        let sections:[NSFetchedResultsSectionInfo] = controller.sections! as [NSFetchedResultsSectionInfo]
        return sections[section].numberOfObjects
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FetchedCollectionCellIdentifier, for: indexPath) as! Cell
        let object = fetchedController!.object(at: indexPath)
        configure(cell: cell, at: indexPath, with: object, forMeasuring: false)
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let object = fetchedController!.object(at: indexPath)
        configure(cell: measuringCell!, at: indexPath, with: object, forMeasuring: true)
        let height = calculateHeightForConfiguredSizingCell(measuringCell!)
        return CGSize(width: collectionView.frame.width, height: height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let object = fetchedController!.object(at: indexPath)
        tappedCell(at: indexPath, object: object)
    }
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        Logging.log("controllerWillChangeContent")
        changeActions = [CollectionCoreDataChangeAction]()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        changeActions.append(CollectionCoreDataChangeAction.action(indexPath, changeType: type, newIndexPath: newIndexPath))
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        Logging.log("controllerDidChangeContent: \(changeActions.count) changes")
        let visible = collectionView.indexPathsForVisibleItems
        
        let updateClosure = {
            for action in self.changeActions {
                let type = action.changeType
                switch(type) {
                case NSFetchedResultsChangeType.update:
                    if (self.ignoreOffScreenUpdates && !visible.contains(action.indexPath!)) {
                        continue
                    }
                    self.collectionView.reloadItems(at: [action.indexPath!])
                case NSFetchedResultsChangeType.insert:
                    self.collectionView.insertItems(at: [action.newIndexPath!])
                case NSFetchedResultsChangeType.delete:
                    self.collectionView.deleteItems(at: [action.indexPath!])
                case NSFetchedResultsChangeType.move:
                    self.collectionView.moveItem(at: action.indexPath!, to: action.newIndexPath!)
                }
            }
        }
        
        let completion: (Bool) -> () = {
            finished in
            
            self.contentChanged()
        }
        
        collectionView.performBatchUpdates(updateClosure, completion: completion)
    }
        
    func contentSizeChanged() {
        DispatchQueue.main.async { () -> Void in
            self.collectionView.reloadData()
        }
    }
    
    public func isEmpty() -> Bool {
        return fetchedController?.fetchedObjects?.count == 0
    }
    
    open func contentChanged() {
        Logging.log("\(#function)")
    }
    
    open func createFetchedController() -> NSFetchedResultsController<Model> {
        fatalError("Need to override \(#function)")
    }
    
    open func configure(cell: Cell, at indexPath: IndexPath, with object: Model, forMeasuring: Bool) {
        Logging.log("configureCell(atIndexPath:\(indexPath))")
    }
    
    open func tappedCell(at indexPath: IndexPath, object object: Model) {
        Logging.log("tappedCell(indexPath:\(indexPath))")
    }
    
    func calculateHeightForConfiguredSizingCell(_ cell: UICollectionViewCell) -> CGFloat {
        var frame = cell.frame
        frame.size.width = collectionView.frame.width
        cell.frame = frame
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        let size = cell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        return size.height
    }
    
    public func hasObject(at indexPath: IndexPath) -> Bool {
        guard let controller = fetchedController else {
            return false
        }
        
        guard let sections = controller.sections, sections.count > indexPath.section else {
            return false
        }
        
        let section = sections[indexPath.section]
        if section.numberOfObjects <= indexPath.row {
            return false
        }
        
        return true
    }
    
    public func object(at indexPath: IndexPath) -> Model {
        return fetchedController!.object(at: indexPath)
    }
}
