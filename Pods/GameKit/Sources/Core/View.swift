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

import SpriteKit

open class View: SKSpriteNode {
    internal weak var game: Game?
    
    private lazy var shadowView: PlatformView = {
        return PlatformView()
    }()
    
    internal var backingView: PlatformView {
        return shadowView
    }

    open func load() {
        
    }
    
    open func unload() {
        
    }
    
    internal func sizeChanged() {
        guard let parent = backingView.superview else {
            return
        }
        
        let parentFrame = parent.bounds
        var myPosition = CGPoint.zero
        myPosition.x = backingView.frame.origin.x
        myPosition.y = parentFrame.height - backingView.bounds.height
        
        position = myPosition
        size = backingView.bounds.size

        for child in children {
            guard let view = child as? View else {
                continue
            }
            
            view.sizeChanged()
        }
    }
    
    public func addSubview(_ view: View) {
        view.anchorPoint = .zero

        let backing = view.backingView
        backing.translatesAutoresizingMaskIntoConstraints = false
        backingView.addSubview(backing)
        
        addChild(view)
        view.load()
    }
    
    public func addConstraints(_ constraints: [LayoutConstraint]) {
        let wrapped = constraints.map({ $0.wrapped })
        backingView.addConstraints(wrapped)
    }
    
    public func add(toTop view: View, height: CGFloat) {
        addSubview(view)
        let views: [String: AnyObject] = ["view": view]
        
        let vertical = LayoutConstraint.constraints(withVisualFormat: "V:|[view(\(height))]", options: [], metrics: nil, views: views)
        let horizontal = LayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: views)
        addConstraints(vertical + horizontal)
    }
    
    public func add(fullSized view: View) {
        addSubview(view)
        
        let views: [String: AnyObject] = ["view": view]
        
        let vertical = LayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: views)
        let horizontal = LayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: views)
        addConstraints(vertical + horizontal)
    }
}
