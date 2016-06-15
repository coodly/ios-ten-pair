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
    public class func multiLineLabel(message: String, font: String, fontSize: CGFloat, maxWidth: CGFloat) -> SKSpriteNode {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .Center
        
        let string = NSMutableAttributedString(string: message)
        let attributes = [
            NSFontAttributeName: UIFont(name: font, size: fontSize)!,
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSParagraphStyleAttributeName: paragraph
        ]
        
        string.setAttributes(attributes, range: NSMakeRange(0, message.characters.count))
        
        let rect = string.boundingRectWithSize(CGSizeMake(maxWidth, 1000), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.mainScreen().scale)
        string.drawInRect(rect)
        
        #if swift(>=2.3)
            let image = UIGraphicsGetImageFromCurrentImageContext()!
        #else
            let image = UIGraphicsGetImageFromCurrentImageContext()
        #endif
        UIGraphicsEndImageContext()
        
        let result = SKSpriteNode(texture: SKTexture(image: image))
        result.colorBlendFactor = 1
        return result
    }
}
