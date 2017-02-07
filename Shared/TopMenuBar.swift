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
    private var menuButton: Button?
    private var reloadButton: Button?
    
    override func load() {
        color = .green
        
        menuButton = Button()
        menuButton?.color = .gray
        addSubview(menuButton!)
        reloadButton = Button()
        reloadButton?.color = .yellow
        addSubview(reloadButton!)
    
        let views: [String: AnyObject] = ["menu": menuButton!, "reload": reloadButton!]
        
        let menuWidth = LayoutConstraint(item: menuButton!, attribute: .width, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0)
        let menuVertical = LayoutConstraint.constraints(withVisualFormat: "V:|[menu]|", options: [], metrics: nil, views: views)
        let menuHorizontal = LayoutConstraint.constraints(withVisualFormat: "H:|-[menu]", options: [], metrics: nil, views: views)

        let reloadWidth = LayoutConstraint(item: reloadButton!, attribute: .width, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0)
        let reloadVertical = LayoutConstraint.constraints(withVisualFormat: "V:|[reload]|", options: [], metrics: nil, views: views)
        let reloadHorizontal = LayoutConstraint.constraints(withVisualFormat: "H:[reload]-|", options: [], metrics: nil, views: views)
        addConstraints(menuVertical + menuHorizontal + reloadVertical + reloadHorizontal + [menuWidth, reloadWidth])
    }
}
