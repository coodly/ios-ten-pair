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
        
        #if os(iOS)
            let labelFont = UIFont(name: font, size: fontSize)!
            let color = UIColor.whiteColor()
        #else
            let labelFont = NSFont(name: font, size: fontSize)!
            let color = NSColor.whiteColor()
        #endif
        
        let string = NSMutableAttributedString(string: message)
        let attributes = [
            NSFontAttributeName: labelFont,
            NSForegroundColorAttributeName: color,
            NSParagraphStyleAttributeName: paragraph
        ]
        
        string.setAttributes(attributes, range: NSMakeRange(0, message.characters.count))
        
        let rect = string.boundingRectWithSize(CGSizeMake(maxWidth, 1000), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        let image = string.render(inBox: rect, attributes: attributes)
        
        let result = SKSpriteNode(texture: SKTexture(image: image))
        result.colorBlendFactor = 1
        return result
    }
}

#if os(iOS)
    import UIKit
    
    private extension NSAttributedString {
        func render(inBox box: CGRect, attributes: [String: AnyObject]) -> UIImage {
            UIGraphicsBeginImageContextWithOptions(box.size, false, UIScreen.mainScreen().scale)
            drawInRect(box)
            
            #if swift(>=2.3)
                let image = UIGraphicsGetImageFromCurrentImageContext()!
            #else
                let image = UIGraphicsGetImageFromCurrentImageContext()
            #endif
            UIGraphicsEndImageContext()
            
            return image
        }
    }
#else
    private extension NSAttributedString {
        func render(inBox box: CGRect, attributes: [String: AnyObject]) -> NSImage {
            let image = NSImage(size: box.size)
            // TODO jaanus: fill in from
            // http://stackoverflow.com/questions/12223739/ios-to-mac-graphiccontext-explanation-conversion
            return image
        }
    }
#endif
