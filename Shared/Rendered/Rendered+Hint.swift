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
    internal class func hintIcon() -> UIImage? {
        let frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
        
        drawHint(frame: frame)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image?.withRenderingMode(.alwaysTemplate)
    }

    internal class func drawHint(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 24, height: 24), resizing: ResizingBehavior = .aspectFit) {
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
        bezierPath.move(to: CGPoint(x: 19, y: 6.73))
        bezierPath.addCurve(to: CGPoint(x: 15.25, y: 17), controlPoint1: CGPoint(x: 19, y: 10.9), controlPoint2: CGPoint(x: 15.25, y: 13.71))
        bezierPath.addLine(to: CGPoint(x: 8.75, y: 17))
        bezierPath.addCurve(to: CGPoint(x: 5, y: 6.73), controlPoint1: CGPoint(x: 8.75, y: 13.71), controlPoint2: CGPoint(x: 5, y: 10.9))
        bezierPath.addCurve(to: CGPoint(x: 12, y: 0), controlPoint1: CGPoint(x: 5, y: 2.39), controlPoint2: CGPoint(x: 8.5, y: 0))
        bezierPath.addCurve(to: CGPoint(x: 19, y: 6.73), controlPoint1: CGPoint(x: 15.5, y: 0), controlPoint2: CGPoint(x: 19, y: 2.39))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 14.5, y: 18))
        bezierPath.addLine(to: CGPoint(x: 9.5, y: 18))
        bezierPath.addCurve(to: CGPoint(x: 9, y: 18.5), controlPoint1: CGPoint(x: 9.22, y: 18), controlPoint2: CGPoint(x: 9, y: 18.22))
        bezierPath.addCurve(to: CGPoint(x: 9.5, y: 19), controlPoint1: CGPoint(x: 9, y: 18.78), controlPoint2: CGPoint(x: 9.22, y: 19))
        bezierPath.addLine(to: CGPoint(x: 14.5, y: 19))
        bezierPath.addCurve(to: CGPoint(x: 15, y: 18.5), controlPoint1: CGPoint(x: 14.78, y: 19), controlPoint2: CGPoint(x: 15, y: 18.78))
        bezierPath.addCurve(to: CGPoint(x: 14.5, y: 18), controlPoint1: CGPoint(x: 15, y: 18.22), controlPoint2: CGPoint(x: 14.78, y: 18))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 14.5, y: 20))
        bezierPath.addLine(to: CGPoint(x: 9.5, y: 20))
        bezierPath.addCurve(to: CGPoint(x: 9, y: 20.5), controlPoint1: CGPoint(x: 9.22, y: 20), controlPoint2: CGPoint(x: 9, y: 20.22))
        bezierPath.addCurve(to: CGPoint(x: 9.5, y: 21), controlPoint1: CGPoint(x: 9, y: 20.78), controlPoint2: CGPoint(x: 9.22, y: 21))
        bezierPath.addLine(to: CGPoint(x: 14.5, y: 21))
        bezierPath.addCurve(to: CGPoint(x: 15, y: 20.5), controlPoint1: CGPoint(x: 14.78, y: 21), controlPoint2: CGPoint(x: 15, y: 20.78))
        bezierPath.addCurve(to: CGPoint(x: 14.5, y: 20), controlPoint1: CGPoint(x: 15, y: 20.22), controlPoint2: CGPoint(x: 14.78, y: 20))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 14.75, y: 22))
        bezierPath.addLine(to: CGPoint(x: 9.25, y: 22))
        bezierPath.addLine(to: CGPoint(x: 10.7, y: 23.66))
        bezierPath.addCurve(to: CGPoint(x: 11.45, y: 24), controlPoint1: CGPoint(x: 10.89, y: 23.87), controlPoint2: CGPoint(x: 11.17, y: 24))
        bezierPath.addLine(to: CGPoint(x: 12.55, y: 24))
        bezierPath.addCurve(to: CGPoint(x: 13.3, y: 23.66), controlPoint1: CGPoint(x: 12.84, y: 24), controlPoint2: CGPoint(x: 13.11, y: 23.87))
        bezierPath.addLine(to: CGPoint(x: 14.75, y: 22))
        bezierPath.close()
        fillColor.setFill()
        bezierPath.fill()
        
        context.restoreGState()
    }
}
