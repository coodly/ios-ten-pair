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
        func renderIn(_ box: CGRect) -> UIImage {
            UIGraphicsBeginImageContextWithOptions(box.size, false, UIScreen.main.scale)
            draw(in: box)
            
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
            // http://stackoverflow.com/questions/12223739/ios-to-mac-graphiccontext-explanation-conversion
            
            let size = box.size
            let image = NSImage(size: size)

            let rep = NSBitmapImageRep.init(bitmapDataPlanes: nil,
                                            pixelsWide: Int(size.width),
                                            pixelsHigh: Int(size.height),
                                            bitsPerSample: 8,
                                            samplesPerPixel: 4,
                                            hasAlpha: true,
                                            isPlanar: false,
                                            colorSpaceName: NSCalibratedRGBColorSpace,
                                            bytesPerRow: 0,
                                            bitsPerPixel: 0)!
            
            image.addRepresentation(rep)
            image.lockFocus()
            
            drawAtPoint(CGPointZero)
            
            image.unlockFocus()
            
            return image
        }
    }
#endif
