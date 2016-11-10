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

class TenPairNumberTile: SKSpriteNode {
    var number = 0
    var numberSprite: SKSpriteNode?
    var backgroundNode: SKSpriteNode?
    
    struct Cache {
        static var imagesCache = [String: SKTexture]()
    }
    
    func defaultPresentaton() {
        if backgroundNode == nil {
            let background = SKSpriteNode()
            backgroundNode = background
            background.size = CGSize(width: self.size.width - 2, height: self.size.height - 2)
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: 1, y: 1)
            addChild(background)
        }
        
        self.numberSprite?.removeFromParent()

        if number == 0 {
            markConsumed()
            return
        }
        
        let numberSprite = spriteForNumber(number)
        numberSprite.color = TenPairTheme.currentTheme.tileNumberColor!
        numberSprite.colorBlendFactor = 1.0
        self.numberSprite = numberSprite
        #if os(iOS)
            numberSprite.position = CGPoint(x: backgroundNode!.size.width / 2, y: backgroundNode!.size.height * 0.75 / 2)
        #else
            numberSprite.anchorPoint = CGPointZero
            numberSprite.position = CGPointMake((backgroundNode!.size.width - numberSprite.size.width) / 2, (backgroundNode!.size.height - numberSprite.size.height) / 2 + backgroundNode!.size.height * 0.2)
        #endif
        backgroundNode!.addChild(numberSprite)
        
        markUnselected()
    }
    
    func markUnselected() {
        backgroundNode!.color = TenPairTheme.currentTheme.defaultNumberTileColor!
    }
    
    func markSelected() {
        backgroundNode!.color = TenPairTheme.currentTheme.selectedTileColor!
    }
    
    func markFailure() {
        backgroundNode!.color = TenPairTheme.currentTheme.errorTileColor!
    }
    
    func markConsumed() {
        backgroundNode!.color = TenPairTheme.currentTheme.consumedTileColor!
    }
    
    func spriteForNumber(_ number: Int) -> SKSpriteNode {
        let imageKey = "\(size.width)-\(number)"
        var numberImage: SKTexture
        if let image = Cache.imagesCache[imageKey] {
            numberImage = image
        } else {
            numberImage = renderImageWithNumber(number, fontSize:size.height * 0.75)
            Cache.imagesCache[imageKey] = numberImage
        }
                
        let sprite = SKSpriteNode(texture: numberImage)
        sprite.name = "numberLabel"
        return sprite
    }
    
    func renderImageWithNumber(_ number: Int, fontSize: CGFloat) -> SKTexture {
        let string = NSMutableAttributedString(string: "\(number)")
        
        #if os(iOS)
            let font = UIFont(name: "ChalkboardSE-Bold", size: fontSize)!
        #else
            let font = NSFont(name: "ChalkboardSE-Bold", size: fontSize)!
        #endif

        let color = SKColor.white
        
        string.addAttribute(NSFontAttributeName, value: font, range: NSMakeRange(0, 1))
        string.addAttribute(NSForegroundColorAttributeName, value: color, range: NSMakeRange(0, 1))
        
        let rect = string.boundingRect(with: CGSize(width: 1000, height: 1000), options: NSStringDrawingOptions.truncatesLastVisibleLine, context: nil)
        
        let image = string.renderIn(rect)
        return SKTexture(image: image)
    }
}
