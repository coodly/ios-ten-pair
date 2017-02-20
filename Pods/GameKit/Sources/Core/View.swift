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

open class View: SKSpriteNode, Themed {
    internal weak var game: Game?    
    private lazy var shadowView: PlatformView = {
        let view = ShadowView()
        view.attached = self
        return view
    }()
    
    internal var backingView: PlatformView {
        return shadowView
    }
    private var hiddenNodes: [SKNode] = []
    internal var delayedAppear = true
    
    public var backgroundColor: SKColor? {
        didSet {
            color = backgroundColor ?? color
        }
    }
    
    open var withTaphHandler: Bool {
        return false
    }
    public var borderWidth: CGFloat = 0 {
        didSet {
            border.lineWidth = borderWidth
        }
    }
    public var borderColor: SKColor = .black {
        didSet {
            border.strokeColor = borderColor
        }
    }
    private lazy var border: SKShapeNode = {
        let node = SKShapeNode()
        self.addChild(node)
        return node
    }()

    internal final func inflate() {
        beforeLoad()
        let before = children
        load()
        afterLoad()
        guard delayedAppear else {
            return
        }
        let after = children.filter({ !before.contains($0) }).filter({ !$0.isHidden })
        for hide in after {
            hide.isHidden = true
        }
        hiddenNodes.append(contentsOf: after)
    }
    
    internal func beforeLoad() {
        
    }
    
    open func load() {
        
    }
    
    internal func afterLoad() {
        guard withTaphHandler else {
            return
        }
        
        attatchTapHandler()
    }
    
    open func unload() {
        
    }
    
    open func update(_ time: TimeInterval) {
        
    }
    
    internal func sizeChanged() {
        guard let parent = backingView.superview else {
            return
        }
        
        let parentFrame = parent.bounds
        var myPosition = CGPoint.zero
        myPosition.x = backingView.frame.origin.x
        myPosition.y = InFlippedEnv ? backingView.frame.minY : parentFrame.height - backingView.frame.maxY
        
        position = myPosition
        size = backingView.bounds.size

        for child in children {
            guard let view = child as? View else {
                continue
            }
            
            view.sizeChanged()
        }
    }
    
    internal func revealHidded() {
        for hidden in hiddenNodes {
            hidden.run(SKAction.unhide())
        }
        hiddenNodes.removeAll()
    }
    
    open func positionChildren() {
        guard borderWidth > 0 else {
            return
        }
        
        var frame = CGRect.zero
        frame.size = size
        let path = CGPath(rect: frame, transform: nil)
        border.path = path
    }
    
    public func addSubview(_ view: View) {
        view.anchorPoint = .zero

        let backing = view.backingView
        backing.translatesAutoresizingMaskIntoConstraints = false
        backingView.addSubview(backing)
        
        addChild(view)
        view.inflate()
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
    
    open func handleTap(at point: CGPoint) {
        
    }

    open func set(color: SKColor, for attribute: Appearance.Attribute) {
        switch attribute {
        case Appearance.Attribute.background:
            backgroundColor = color
        default:
            break // no op
        }
    }
    
    open func set(value: String, for attribute: Appearance.Attribute) {
        //No op
    }
}
