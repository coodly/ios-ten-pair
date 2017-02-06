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

internal extension UIView {
    func fullSizedReference() -> ReferenceView {
        let reference = ReferenceView(frame: bounds)
        reference.backgroundColor = .clear
        add(fullSized: reference)
        return reference
    }
    
    func topReference(withHeight height: CGFloat) -> ReferenceView {
        var referenceFrame = bounds
        referenceFrame.size.height = height
        
        let reference = ReferenceView(frame: referenceFrame)
        add(toTop: reference, height: height)
        return reference
    }
    
    private func add(fullSized view: UIView) {
        addSubview(view)
        let views: [String: AnyObject] = ["view": view]
        
        view.translatesAutoresizingMaskIntoConstraints = false
        let vertical = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: views)
        let horizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: views)
        addConstraints(vertical + horizontal)
    }

    private func add(toTop view: UIView, height: CGFloat) {
        addSubview(view)
        let views: [String: AnyObject] = ["view": view]
        
        view.translatesAutoresizingMaskIntoConstraints = false
        let vertical = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view(\(height))]", options: [], metrics: nil, views: views)
        let horizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: views)
        addConstraints(vertical + horizontal)
    }
}
