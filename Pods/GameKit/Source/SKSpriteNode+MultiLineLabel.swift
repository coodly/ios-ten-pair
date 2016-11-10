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

public extension SKSpriteNode {
    public class func multiLineLabel(_ message: String, font: String, fontSize: CGFloat, maxWidth: CGFloat) -> SKSpriteNode {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        #if os(iOS)
            let labelFont = UIFont(name: font, size: fontSize)!
        #else
            let labelFont = NSFont(name: font, size: fontSize)!
        #endif
        let color = SKColor.white
        
        let string = NSMutableAttributedString(string: message)
        let attributes = [
            NSFontAttributeName: labelFont,
            NSForegroundColorAttributeName: color,
            NSParagraphStyleAttributeName: paragraph
        ]
        
        string.setAttributes(attributes, range: NSMakeRange(0, message.characters.count))
        
        let rect = string.boundingRect(with: CGSize(width: maxWidth, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        let image = string.renderIn(rect)
        
        let result = SKSpriteNode(texture: SKTexture(image: image))
        result.colorBlendFactor = 1
        return result
    }
}
