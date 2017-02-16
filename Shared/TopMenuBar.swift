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

import GameKit

class TopMenuBar: View {    
    var menuButton: Button?
    var reloadButton: Button?
    var statusView: FieldStatusView?
    
    override func load() {
        menuButton = Button()
        menuButton?.name = "Menu button"
        menuButton?.set(icon: "menu")
        addSubview(menuButton!)
        
        reloadButton = Button()
        reloadButton?.name = "Reload button"
        reloadButton?.set(icon: "reload")
        addSubview(reloadButton!)
        
        statusView = FieldStatusView()
        addSubview(statusView!)
    
        let views: [String: AnyObject] = ["menu": menuButton!, "reload": reloadButton!, "status": statusView!]
        
        let menuWidth = LayoutConstraint(item: menuButton!, attribute: .width, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0)
        let menuVertical = LayoutConstraint.constraints(withVisualFormat: "V:|[menu]|", options: [], metrics: nil, views: views)

        let reloadWidth = LayoutConstraint(item: reloadButton!, attribute: .width, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0)
        let reloadVertical = LayoutConstraint.constraints(withVisualFormat: "V:|[reload]|", options: [], metrics: nil, views: views)
        let statusVertical = LayoutConstraint.constraints(withVisualFormat: "V:|[status]|", options: [], metrics: nil, views: views)

        let horizontal = LayoutConstraint.constraints(withVisualFormat: "H:|-[menu]-[status]-[reload]-|", options: [], metrics: nil, views: views)

        addConstraints(menuVertical + reloadVertical + horizontal + [menuWidth, reloadWidth] + statusVertical)
    }
}
