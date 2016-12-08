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
import SpriteKit
import GameKit

class TenPairMenuButton: MenuButton {
    fileprivate var titleLabel: SKLabelNode?
    var titleFontSize: CGFloat = 20 {
        didSet {
            titleLabel?.fontSize = titleFontSize
        }
    }
    
    func setTitle(_ title: String) {
        if let existing = titleLabel {
            existing.removeFromParent()
        }
        
        name = title
        let label = SKLabelNode(fontNamed: "Copperplate-Bold")
        label.text = title
        label.fontSize = titleFontSize
        label.fontColor = TenPairTheme.currentTheme.menuTitleColor!
        label.position = CGPoint(x: size.width / 2, y: (size.height - label.frame.size.height) / 2)
        addChild(label)
        
        titleLabel = label
        
        positionContent()
    }
    
    override func positionContent() {
        guard let label = titleLabel else {
            return
        }
        
        label.position = CGPoint(x: size.width / 2, y: (size.height - label.frame.size.height) / 2)
    }
    
    class func menuItemWithTitle(_ title: String, closure: @escaping () -> ()) -> TenPairMenuButton {
        let item = TenPairMenuButton()
        item.setTitle(title)
        item.color = TenPairTheme.currentTheme.menuOptionBackgroundColor!
        item.action = SKAction.run(closure)
        
        return item
    }
}
