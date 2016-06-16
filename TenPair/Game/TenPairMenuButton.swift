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

class TenPairMenuButton: GameMenuButton {
    private var titleLabel: SKLabelNode?
    var titleFontSize: CGFloat = 20 {
        didSet {
            titleLabel?.fontSize = titleFontSize
        }
    }
    
    func setTitle(title: String) {
        name = title
        let label = SKLabelNode(fontNamed: "Copperplate-Bold")
        label.text = title
        label.fontSize = titleFontSize
        label.fontColor = TenPairTheme.currentTheme.menuTitleColor!
        label.position = CGPointMake(size.width / 2, (size.height - label.frame.size.height) / 2)
        addChild(label)
        
        titleLabel = label
    }
    
    override func positionContent() {
        guard let label = titleLabel else {
            return
        }
        
        label.position = CGPointMake(size.width / 2, (size.height - label.frame.size.height) / 2)
    }
    
    class func menuItemWithTitle(title: String, closure: () -> ()) -> TenPairMenuButton {
        let item = TenPairMenuButton()
        item.setTitle(title)
        item.color = TenPairTheme.currentTheme.menuOptionBackgroundColor!
        item.action = SKAction.runBlock(closure)
        
        return item
    }
}
