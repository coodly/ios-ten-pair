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
    static let title = UUID().uuidString
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
        }
    }
    
    internal var icon: SKSpriteNode?
    
    override func sizeChanged() {
        super.sizeChanged()
        
        positionIcon()
    }
    
    open override func set(_ color: SKColor, for attribute: Appearance.Attribute) {
        super.set(color, for: attribute)
        
        switch attribute {
        case Appearance.Attribute.foreground:
            tintColor = color
        default:
            break //no op
        }
    }
}

internal extension Button {
    @objc fileprivate func tapped() {
        guard let action = action else {
            return
        }
        
        run(action)
    }
}

public extension Button {
    public func set(icon named: String) {
        icon = SKSpriteNode(imageNamed: named)
        addChild(icon!)
    }
    
    internal func positionIcon() {
        if let tint = tintColor {
            icon?.color = tint
            icon?.colorBlendFactor = 1
        }
        
        icon?.size = size
        icon?.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }
}
