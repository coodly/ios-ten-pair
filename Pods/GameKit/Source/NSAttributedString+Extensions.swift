/*
 * Copyright 2016 Coodly LLC
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

#if os(iOS)
    import UIKit
    
    public extension NSAttributedString {
        func renderIn(box: CGRect) -> UIImage {
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
    public extension NSAttributedString {
        func renderIn(box: CGRect) -> NSImage {
            let image = NSImage(size: box.size)
            // TODO jaanus: fill in from
            // http://stackoverflow.com/questions/12223739/ios-to-mac-graphiccontext-explanation-conversion
            return image
        }
    }
#endif
