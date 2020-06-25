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
    internal class func drawSquare(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 24, height: 24), color: UIColor, resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 24, height: 24), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 24, y: resizedFrame.height / 24)


        //// Color Declarations
        let fillColor = color

        //// Rectangle Drawing
        let rectanglePath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 24, height: 24))
        fillColor.setFill()
        rectanglePath.fill()
        
        context.restoreGState()
    }
}

internal class TileIconView: UIView {
    override func draw(_ rect: CGRect) {
        Rendered.drawSquare(frame: bounds, color: tintColor, resizing: .aspectFit)
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        
        setNeedsDisplay()
    }
}
