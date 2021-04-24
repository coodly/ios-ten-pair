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
    public static let undoIcon = drawIcon()
    
    private class func drawIcon() -> UIImage? {
        let frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
        
        drawUndo(frame: frame)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image?.withRenderingMode(.alwaysTemplate)
    }

    private class func drawUndo(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 24, height: 24), resizing: ResizingBehavior = .aspectFit) {
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
        bezierPath.move(to: CGPoint(x: 18.89, y: 3.52))
        bezierPath.addCurve(to: CGPoint(x: 2.13, y: 3.32), controlPoint1: CGPoint(x: 14.27, y: -1.1), controlPoint2: CGPoint(x: 6.83, y: -1.16))
        bezierPath.addLine(to: CGPoint(x: 0, y: 1.06))
        bezierPath.addLine(to: CGPoint(x: 0, y: 9))
        bezierPath.addLine(to: CGPoint(x: 7.48, y: 9))
        bezierPath.addLine(to: CGPoint(x: 5.42, y: 6.81))
        bezierPath.addCurve(to: CGPoint(x: 15.49, y: 6.91), controlPoint1: CGPoint(x: 8.24, y: 4.1), controlPoint2: CGPoint(x: 12.72, y: 4.13))
        bezierPath.addCurve(to: CGPoint(x: 10, y: 19.2), controlPoint1: CGPoint(x: 19.83, y: 11.25), controlPoint2: CGPoint(x: 17.23, y: 19.2))
        bezierPath.addLine(to: CGPoint(x: 10, y: 24))
        bezierPath.addCurve(to: CGPoint(x: 18.89, y: 20.49), controlPoint1: CGPoint(x: 13.71, y: 24), controlPoint2: CGPoint(x: 16.61, y: 22.76))
        bezierPath.addCurve(to: CGPoint(x: 18.89, y: 3.52), controlPoint1: CGPoint(x: 23.57, y: 15.8), controlPoint2: CGPoint(x: 23.57, y: 8.2))
        bezierPath.close()
        fillColor.setFill()
        bezierPath.fill()
        
        context.restoreGState()

    }
}
