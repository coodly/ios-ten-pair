/*
* Copyright 2020 Coodly LLC
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

import UIKit

extension Rendered {
    public static let menuIcon = drawIcon()
    
    private class func drawIcon() -> UIImage? {
        let frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
        
        drawMenu(frame: frame)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image?.withRenderingMode(.alwaysTemplate)
    }

    private class func drawMenu(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 24, height: 24), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 24, height: 24), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 24, y: resizedFrame.height / 24)


        //// Color Declarations
        let fillColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)

        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 12, y: 0))
        bezierPath.addCurve(to: CGPoint(x: 0, y: 12), controlPoint1: CGPoint(x: 5.37, y: 0), controlPoint2: CGPoint(x: 0, y: 5.37))
        bezierPath.addCurve(to: CGPoint(x: 12, y: 24), controlPoint1: CGPoint(x: 0, y: 18.63), controlPoint2: CGPoint(x: 5.37, y: 24))
        bezierPath.addCurve(to: CGPoint(x: 24, y: 12), controlPoint1: CGPoint(x: 18.63, y: 24), controlPoint2: CGPoint(x: 24, y: 18.63))
        bezierPath.addCurve(to: CGPoint(x: 12, y: 0), controlPoint1: CGPoint(x: 24, y: 5.37), controlPoint2: CGPoint(x: 18.63, y: 0))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 18, y: 17))
        bezierPath.addLine(to: CGPoint(x: 6, y: 17))
        bezierPath.addLine(to: CGPoint(x: 6, y: 15))
        bezierPath.addLine(to: CGPoint(x: 18, y: 15))
        bezierPath.addLine(to: CGPoint(x: 18, y: 17))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 18, y: 13))
        bezierPath.addLine(to: CGPoint(x: 6, y: 13))
        bezierPath.addLine(to: CGPoint(x: 6, y: 11))
        bezierPath.addLine(to: CGPoint(x: 18, y: 11))
        bezierPath.addLine(to: CGPoint(x: 18, y: 13))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 18, y: 9))
        bezierPath.addLine(to: CGPoint(x: 6, y: 9))
        bezierPath.addLine(to: CGPoint(x: 6, y: 7))
        bezierPath.addLine(to: CGPoint(x: 18, y: 7))
        bezierPath.addLine(to: CGPoint(x: 18, y: 9))
        bezierPath.close()
        fillColor.setFill()
        bezierPath.fill()
        
        context.restoreGState()
    }
}
