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
            background.size = CGSizeMake(self.size.width - 2, self.size.height - 2)
            background.anchorPoint = CGPointZero
            background.position = CGPointMake(1, 1)
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
        numberSprite.position = CGPointMake(backgroundNode!.size.width / 2, backgroundNode!.size.height * 0.75 / 2)
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
    
    func spriteForNumber(number: Int) -> SKSpriteNode {
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
    
    func renderImageWithNumber(number: Int, fontSize: CGFloat) -> SKTexture {
        let string = NSMutableAttributedString(string: "\(number)")
        string.addAttribute(NSFontAttributeName, value: UIFont(name: "ChalkboardSE-Bold", size: fontSize)!, range: NSMakeRange(0, 1))
        string.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, 1))
        
        let rect = string.boundingRectWithSize(CGSizeMake(1000, 1000), options: NSStringDrawingOptions.TruncatesLastVisibleLine, context: nil)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.mainScreen().scale)
        string.drawInRect(rect)
        
        #if swift(>=2.3)
            let image = UIGraphicsGetImageFromCurrentImageContext()!
        #else
            let image = UIGraphicsGetImageFromCurrentImageContext()
        #endif
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image)
    }
}
