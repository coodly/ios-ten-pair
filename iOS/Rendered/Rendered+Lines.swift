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
    internal class func drawLines(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 24, height: 24), color: UIColor, resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 20, height: 20), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 20, y: resizedFrame.height / 20)


        //// Color Declarations
        let fillColor = color

        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 24, y: 4))
        bezierPath.addLine(to: CGPoint(x: 0, y: 4))
        bezierPath.addLine(to: CGPoint(x: 0, y: 0))
        bezierPath.addLine(to: CGPoint(x: 24, y: 0))
        bezierPath.addLine(to: CGPoint(x: 24, y: 4))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 24, y: 8))
        bezierPath.addLine(to: CGPoint(x: 0, y: 8))
        bezierPath.addLine(to: CGPoint(x: 0, y: 12))
        bezierPath.addLine(to: CGPoint(x: 24, y: 12))
        bezierPath.addLine(to: CGPoint(x: 24, y: 8))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 24, y: 16))
        bezierPath.addLine(to: CGPoint(x: 0, y: 16))
        bezierPath.addLine(to: CGPoint(x: 0, y: 20))
        bezierPath.addLine(to: CGPoint(x: 24, y: 20))
        bezierPath.addLine(to: CGPoint(x: 24, y: 16))
        bezierPath.close()
        fillColor.setFill()
        bezierPath.fill()
        
        context.restoreGState()
    }
}

internal class LinesIconView: UIView {
    override func draw(_ rect: CGRect) {
        Rendered.drawLines(frame: bounds, color: tintColor, resizing: .aspectFit)
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        
        setNeedsDisplay()
    }
}
