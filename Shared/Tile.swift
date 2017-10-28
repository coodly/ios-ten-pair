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
import GameKit
import SpriteKitUI

struct ColorSet {
    var tileColor: SKColor = .clear
    var tileNumberColor: SKColor = .clear
    var selectedColor: SKColor = .clear
    var successColor: SKColor = .clear
    var failureColor: SKColor = .clear
    var consumedColor: SKColor = .clear
}

private enum State {
    case normal
    case selected
    case consumed
    case succss
    case failure
}

class Tile: SKSpriteNode {
    private static var textureCache = [String: SKTexture]()
    
    var number = 0
    private var numberSprite: SKSpriteNode?
    
    var colors: ColorSet! {
        didSet {
            updateColors()
        }
    }
    
    lazy var backgroundNode: SKSpriteNode = {
        let background = SKSpriteNode()
        background.anchorPoint = CGPoint.zero
        background.position = CGPoint(x: 1, y: 1)
        self.addChild(background)
        return background
    }()
    
    private var state: State = .normal {
        didSet {
            updateColors()
        }
    }
    
    private func updateColors() {
        if number == 0 {
            backgroundNode.color = colors.consumedColor
            return
        }
        
        switch state {
        case .normal:
            backgroundNode.color = colors.tileColor
        case .selected:
            backgroundNode.color = colors.selectedColor
        case .consumed:
            backgroundNode.color = colors.consumedColor
        case .succss:
            backgroundNode.color = colors.successColor
        case .failure:
            backgroundNode.color = colors.failureColor
        }
    }
    
    func defaultPresentaton() {
        backgroundNode.size = CGSize(width: self.size.width - 2, height: self.size.height - 2)

        self.numberSprite?.removeFromParent()

        guard number > 0 else {
            markConsumed()
            return
        }
        
        let numberSprite = spriteForNumber(number)
        numberSprite.color = colors.tileNumberColor
        numberSprite.colorBlendFactor = 1.0
        self.numberSprite = numberSprite

        center(numberSprite, in: backgroundNode)
        backgroundNode.addChild(numberSprite)
        
        markUnselected()
    }
    
    func markConsumed() {
        state = .consumed
    }
    
    func markUnselected() {
        state = .normal
    }
    
    func markSelected() {
        state = .selected
    }
    
    private func spriteForNumber(_ number: Int) -> SKSpriteNode {
        let imageKey = "\(size.width)-\(number)"
        var numberImage: SKTexture
        if let image = Tile.textureCache[imageKey] {
            numberImage = image
        } else {
            numberImage = renderImageWithNumber(number, fontSize:size.height * 0.75)
            Tile.textureCache[imageKey] = numberImage
        }
        
        let sprite = SKSpriteNode(texture: numberImage)
        sprite.name = "numberLabel"
        return sprite
    }
    
    private func renderImageWithNumber(_ number: Int, fontSize: CGFloat) -> SKTexture {
        let string = NSMutableAttributedString(string: "\(number)")
        
        let font = Font(name: "ChalkboardSE-Bold", size: fontSize)!
        
        let color = SKColor.white
        
        string.addAttribute(NSAttributedStringKey.font, value: font, range: NSMakeRange(0, 1))
        string.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: NSMakeRange(0, 1))
        
        let rect = string.boundingRect(with: CGSize(width: 1000, height: 1000), options: StringDrawingOptions.truncatesLastVisibleLine, context: nil)
        
        let image = string.renderIn(rect)
        return SKTexture(image: image)
    }

}
