/*
 * Copyright 201& Coodly LLC
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

// Taken from http://www.raizlabs.com/dev/2016/05/smarter-animated-row-deselection-ios/

import Foundation

protocol SmoothTableRowDeselection {
    var tableView: UITableView! { get }
    
    func smoothDeselectRows()
}

extension SmoothTableRowDeselection where Self: UIViewController {
    func smoothDeselectRows() {
        guard let selectedPaths = tableView.indexPathsForSelectedRows else {
            return
        }
        
        guard let coordinator = transitionCoordinator else {
            for selected in selectedPaths {
                tableView.deselectRow(at: selected, animated: false)
            }
            return
        }
        
        coordinator.animateAlongsideTransition(in: parent?.view, animation: {
            context in
        
            for selected in selectedPaths {
                self.tableView.deselectRow(at: selected, animated: context.isAnimated)
            }
        }, completion: {
            context in
        
            if context.isCancelled {
                for selected in selectedPaths {
                    self.tableView.selectRow(at: selected, animated: false, scrollPosition: .none)
                }
            }
        })
    }
}
