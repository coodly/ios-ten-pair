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

enum Status {
    case enabled
    case disabed
}

open class GameButton : GameView {
    open var action: SKAction?
    open var touchDisables = false
    open var image: SKSpriteNode?
    var status: Status = .enabled
    
    open class func buttonWithImage(_ imageName: String, closure: @escaping () -> ()) -> GameButton {
        return GameButton.buttonWithImage(imageName, action: SKAction.run(closure))
    }

    open class func buttonWithImage(_ imageName: String, action: SKAction) -> GameButton {
        let button = GameButton()
        let image = SKSpriteNode(imageNamed: imageName)
        button.image = image
        button.action = action
        button.addChild(image)
        return button
    }
    
    open override func positionContent() {
        super.positionContent()
 
        guard let image = image else {
            return
        }
        
        image.size = fitSizeToHeight(image.size, height: size.height)
        image.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
    open func disable() {
        status = .disabed
    }
    
    open func enable() {
        status = .enabled
    }
    
    func isEnabled() -> Bool {
        return status == .enabled
    }
}

private extension GameButton {
    func fitSizeToHeight(_ size: CGSize, height: CGFloat) -> CGSize {
        let ratio = height / size.height
        return CGSize(width: size.width * ratio, height: height)
    }
}
