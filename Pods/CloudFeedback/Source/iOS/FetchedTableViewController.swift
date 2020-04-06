/*
 * Copyright 2018 Coodly LLC
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
import CoreData

private typealias ConformsTo = UITableViewDataSource & UITableViewDelegate & NSFetchedResultsControllerDelegate

public class FetchedTableViewController<Model: NSManagedObject, Cell: UITableViewCell>: UIViewController, ConformsTo {
    private(set) var tableView: UITableView!
    
    open var rowAnimation: UITableView.RowAnimation {
        return .automatic
    }
    
    private var elements: NSFetchedResultsController<Model>?
    
    public var numberOfItems: Int {
        return elements?.fetchedObjects?.count ?? 0
    }
    
    deinit {
        elements?.delegate = nil
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView()
        view.addSubview(tableView)
        tableView.pinToSuperviewEdges()

        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard elements == nil else {
            return
        }
        
        elements = createFetchedController()
        elements?.delegate = self
        tableView.reloadData()
    }
    
    internal func createFetchedController() -> NSFetchedResultsController<Model> {
        fatalError()
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return elements?.sections?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let controller = elements else {
            return 0
        }
        
        let sections:[NSFetchedResultsSectionInfo] = controller.sections! as [NSFetchedResultsSectionInfo]
        return sections[section].numberOfObjects
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as Cell
        let object = elements!.object(at: indexPath)
        configure(cell, with: object, at: indexPath)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selected = elements!.object(at: indexPath)
        tapped(on: selected, at: indexPath)
    }
    
    internal func configure(_ cell: Cell, with model: Model, at indexPath: IndexPath) {
        
    }
    
    internal func tapped(on model: Model, at indexPath: IndexPath) {
        
    }
    
    internal func object(at indexPath: IndexPath) -> Model {
        return elements!.object(at: indexPath)
    }
    
    internal func updateFetch(_ predicate: NSPredicate) {
        elements?.fetchRequest.predicate = predicate
        try! elements?.performFetch()
        tableView.reloadData()
    }
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch(type) {
        case .update:
            tableView.reloadSections(IndexSet(integer: sectionIndex), with: .none)
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .none)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .none)
        case .move:
            fatalError("Wut? \(sectionIndex)")
        @unknown default:
            Logging.log("Unknown \(type.rawValue)")
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch(type) {
        case NSFetchedResultsChangeType.update where indexPath == newIndexPath:
            tableView.reloadRows(at: [indexPath!], with: rowAnimation)
        case .update where newIndexPath != nil:
            tableView.deleteRows(at: [indexPath!], with: rowAnimation)
            tableView.insertRows(at: [newIndexPath!], with: rowAnimation)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: rowAnimation)
        case NSFetchedResultsChangeType.insert:
            tableView.insertRows(at: [newIndexPath!], with: rowAnimation)
        case NSFetchedResultsChangeType.delete:
            tableView.deleteRows(at: [indexPath!], with: rowAnimation)
        case NSFetchedResultsChangeType.move:
            tableView.deleteRows(at: [indexPath!], with: rowAnimation)
            tableView.insertRows(at: [newIndexPath!], with: rowAnimation)
        @unknown default:
            Logging.log("Unknown \(type.rawValue)")
        }
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
