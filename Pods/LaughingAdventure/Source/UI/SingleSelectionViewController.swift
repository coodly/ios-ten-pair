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

open class SingleSelectionViewController: SelectionViewController {
    public var selectionHandler: ((AnyObject?) -> Void)!
    var selectedElement: AnyObject?
        
    open override func viewWillDisappear(_ animated: Bool) {
        selectionHandler(selectedElement)
    }

    override func isSelected(_ object: AnyObject) -> Bool {
        return object.isEqual(selectedElement)
    }
    
    public override func tappedCell(_ atIndexPath: IndexPath, object: AnyObject) {
        moveSelectionToElement(object)
    }
    
    public func markSelected(_ element: AnyObject) {
        moveSelectionToElement(element)
    }
    
    func moveSelectionToElement(_ element: AnyObject) {
        tableView.beginUpdates()
        
        
        if let previous = selectedElement, let previousIndexPath = source.indexPathForObject(previous) {
            tableView.reloadRows(at: [previousIndexPath], with: UITableViewRowAnimation.automatic)
        }
        
        selectedElement = element
        if let selectedIndexPath = source.indexPathForObject(element) {
            tableView.reloadRows(at: [selectedIndexPath], with: UITableViewRowAnimation.automatic)
        }
        
        tableView.endUpdates()
    }
}
