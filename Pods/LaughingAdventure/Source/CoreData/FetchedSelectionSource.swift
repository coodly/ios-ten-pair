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

import CoreData

#if os(iOS)
public class FetchedSelectionSource<T: NSFetchRequestResult>: NSObject, SelectionSource, NSFetchedResultsControllerDelegate {
    private var fetchedController: NSFetchedResultsController<T>!
    public var tableView: UITableView!
    
    override init() {

    }
    
    public convenience init(fetchedController: NSFetchedResultsController<T>) {
        self.init()
        
        self.fetchedController = fetchedController
        self.fetchedController.delegate = self
    }
    
    public func numberOfSections() -> Int {
        guard let sections = fetchedController.sections else {
            return 0
        }
        
        return sections.count
    }
    
    public func numberOfRowsInSection(_ section: Int) -> Int {
        let sections:[NSFetchedResultsSectionInfo] = fetchedController.sections! as [NSFetchedResultsSectionInfo]
        return sections[section].numberOfObjects
    }
    
    public func objectAtIndexPath(_ indexPath: IndexPath) -> AnyObject {
        return fetchedController.object(at: indexPath)
    }
    
    public func indexPathForObject(_ object: AnyObject) -> IndexPath? {
        guard let fetched = object as? T else {
            return nil
        }
        
        return fetchedController.indexPath(forObject: fetched)
    }
    
    //TODO jaanus: copy/paste....
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {        
        switch(type) {
        case NSFetchedResultsChangeType.insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case NSFetchedResultsChangeType.delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case NSFetchedResultsChangeType.update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        case NSFetchedResultsChangeType.move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

}

#endif
