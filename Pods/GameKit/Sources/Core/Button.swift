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

public extension Appearance.Attribute {
    static let font = UUID().uuidString
    static let fontSize = UUID().uuidString
}

internal extension Selector {
    static let buttonTapped = #selector(Button.tapped)
}

open class Button: View {
    private lazy var button: PlatformView = {
        return self.createPlatformButton()
    }()
    
    override var backingView: PlatformView {
        return button
    }
    
    public var action: SKAction?
    public var tintColor: SKColor? {
        didSet {
            guard let tint = tintColor else {
                return
            }
            icon?.color = tint
            title?.fontColor = tint
        }
    }
    
    fileprivate var icon: SKSpriteNode?
    fileprivate var title: SKLabelNode?
    fileprivate var titleFont: String? {
        didSet {
            title?.fontName = titleFont
        }
    }
    
    override open func positionChildren() {
        super.positionChildren()
        
        positionIcon()
        positionTitle()
    }
    
    open override func set(color: SKColor, for attribute: Appearance.Attribute) {
        super.set(color: color, for: attribute)
        
        switch attribute {
        case Appearance.Attribute.foreground:
            tintColor = color
        default:
            break //no op
        }
    }
    
    open override func set(value: String, for attribute: Appearance.Attribute) {
        super.set(value: value, for: attribute)
        
        switch attribute {
        case Appearance.Attribute.font:
            titleFont = value
        default:
            break // no op
        }
    }

    @objc fileprivate func tapped() {
        guard let action = action else {
            return
        }
        
        run(action)
    }
}

public extension Button {
    public func set(icon named: String) {
        icon?.removeFromParent()
        icon = SKSpriteNode(imageNamed: named)
        icon?.colorBlendFactor = 1
        addChild(icon!)
    }
    
    internal func positionIcon() {
        icon?.size = size
        icon?.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }
}

public extension Button {
    public func set(title: String) {
        self.title?.removeFromParent()
        self.title = SKLabelNode(text: title)
        self.title?.fontName = self.titleFont
        addChild(self.title!)
    }
    
    fileprivate func positionTitle() {
        guard let label = title else {
            return
        }
        
        label.position = CGPoint(x: size.width / 2, y: (size.height - label.frame.height) / 2)
    }
}
