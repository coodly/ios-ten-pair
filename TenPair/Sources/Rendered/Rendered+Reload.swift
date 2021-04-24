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
    public static let reloadIcon = drawIcon()
    
    private class func drawIcon() -> UIImage? {
        let frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
        
        drawReload(frame: frame)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image?.withRenderingMode(.alwaysTemplate)
    }

    private class func drawReload(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 24, height: 24), resizing: ResizingBehavior = .aspectFit) {
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 24, height: 18), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 24, y: resizedFrame.height / 18)


        //// Color Declarations
        let fillColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)

        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 9, y: 9))
        bezierPath.addLine(to: CGPoint(x: 4.54, y: 13.97))
        bezierPath.addLine(to: CGPoint(x: 0, y: 9))
        bezierPath.addLine(to: CGPoint(x: 3, y: 9))
        bezierPath.addCurve(to: CGPoint(x: 12, y: 0), controlPoint1: CGPoint(x: 3, y: 4.03), controlPoint2: CGPoint(x: 7.03, y: 0))
        bezierPath.addCurve(to: CGPoint(x: 18.18, y: 2.47), controlPoint1: CGPoint(x: 14.39, y: 0), controlPoint2: CGPoint(x: 16.57, y: 0.94))
        bezierPath.addLine(to: CGPoint(x: 16.18, y: 4.7))
        bezierPath.addCurve(to: CGPoint(x: 12, y: 3), controlPoint1: CGPoint(x: 15.09, y: 3.65), controlPoint2: CGPoint(x: 13.62, y: 3))
        bezierPath.addCurve(to: CGPoint(x: 6, y: 9), controlPoint1: CGPoint(x: 8.69, y: 3), controlPoint2: CGPoint(x: 6, y: 5.69))
        bezierPath.addLine(to: CGPoint(x: 9, y: 9))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 19.46, y: 4.03))
        bezierPath.addLine(to: CGPoint(x: 15, y: 9))
        bezierPath.addLine(to: CGPoint(x: 18, y: 9))
        bezierPath.addCurve(to: CGPoint(x: 12, y: 15), controlPoint1: CGPoint(x: 18, y: 12.31), controlPoint2: CGPoint(x: 15.31, y: 15))
        bezierPath.addCurve(to: CGPoint(x: 7.83, y: 13.3), controlPoint1: CGPoint(x: 10.38, y: 15), controlPoint2: CGPoint(x: 8.91, y: 14.35))
        bezierPath.addLine(to: CGPoint(x: 5.82, y: 15.53))
        bezierPath.addCurve(to: CGPoint(x: 12, y: 18), controlPoint1: CGPoint(x: 7.43, y: 17.06), controlPoint2: CGPoint(x: 9.61, y: 18))
        bezierPath.addCurve(to: CGPoint(x: 21, y: 9), controlPoint1: CGPoint(x: 16.97, y: 18), controlPoint2: CGPoint(x: 21, y: 13.97))
        bezierPath.addLine(to: CGPoint(x: 24, y: 9))
        bezierPath.addLine(to: CGPoint(x: 19.46, y: 4.03))
        bezierPath.close()
        fillColor.setFill()
        bezierPath.fill()
        
        context.restoreGState()
    }
}
