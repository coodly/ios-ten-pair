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

import UIKit

open class MultiSelectionViewController: SelectionViewController {
    public var selectionHandler: (([AnyObject]) -> Void)!
    var selectedElements: [AnyObject]!
 
    open override func viewWillDisappear(_ animated: Bool) {
        selectionHandler(selectedElements)
    }

    override func isSelected(_ object: AnyObject) -> Bool {
        return selectedElements.contains( where: { $0.isEqual(object)} )
    }
    
    public func markSelectedElements(_ selected: [AnyObject]) {
        selectedElements = selected
        tableView.reloadData()
    }
    
    public override func tappedCell(_ atIndexPath: IndexPath, object: AnyObject) {
        if isSelected(object), let index = selectedElements.index(where: { $0.isEqual(object) }) {
            let removed = selectedElements.remove(at: index)
            didDeselect(removed)
        } else {
            selectedElements.append(object)
            didSelect(object)
        }
        
        tableView.beginUpdates()
        tableView.reloadRows(at: [atIndexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    public func addToSelected(_ object: AnyObject) {
        selectedElements.append(object)
        tableView.reloadData()
    }
    
    public func didSelect(_ element: AnyObject) {
        
    }

    open func didDeselect(_ element: AnyObject) {
        
    }
}
