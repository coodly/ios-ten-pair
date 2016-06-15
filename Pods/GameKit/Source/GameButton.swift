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

public class GameButton : GameView {
    public var action: SKAction?
    public var touchDisables = false
    public var image: SKSpriteNode?
    
    public class func buttonWithImage(imageName: String, action: () -> ()) -> GameButton {
        let button = GameButton()
        let image = SKSpriteNode(imageNamed: imageName)
        button.image = image
        button.action = SKAction.runBlock(action)
        button.addChild(image)
        return button
    }
    
    public override func positionContent() {
        super.positionContent()
 
        guard let image = image else {
            return
        }
        
        image.size = fitSizeToHeight(image.size, height: size.height)
        image.position = CGPointMake(size.width / 2, size.height / 2)
    }
}

private extension GameButton {
    func fitSizeToHeight(size: CGSize, height: CGFloat) -> CGSize {
        let ratio = height / size.height
        return CGSizeMake(size.width * ratio, height)
    }
}