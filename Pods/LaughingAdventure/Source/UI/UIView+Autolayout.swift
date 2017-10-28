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

public extension UIView {
    public func add(fullSized view: UIView) {
        addSubview(view)
        let views: [String: AnyObject] = ["view": view]
        
        view.translatesAutoresizingMaskIntoConstraints = false
        let vertical = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: views)
        let horizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: views)
        addConstraints(vertical + horizontal)
    }

    public func add(toTop view: UIView, height: CGFloat? = nil) {
        addSubview(view)
        let views: [String: AnyObject] = ["view": view]
        
        let usedHeight = height ?? view.frame.height
        
        view.translatesAutoresizingMaskIntoConstraints = false
        let horizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: views)
        
        let top = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let heightConstraint: NSLayoutConstraint
        if usedHeight < 1 {
            heightConstraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
        } else {
            heightConstraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: usedHeight)
        }
        
        let vertical = [top, heightConstraint]
        
        addConstraints(vertical + horizontal)
    }
}
