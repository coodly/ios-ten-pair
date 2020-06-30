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

internal class SpinnerView: UIView {
    private var path: UIBezierPath?
    private var timer: Timer? {
        didSet {
            oldValue?.invalidate()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let linWidth = CGFloat(15)
        let used = bounds.insetBy(dx: linWidth / 2, dy: linWidth / 2)
        path = UIBezierPath(arcCenter: CGPoint(x: used.midX, y: used.midY), radius: used.width / 2, startAngle: CGFloat(0).radians, endAngle: CGFloat(310).radians, clockwise: true)
        path?.lineCapStyle = .round
        path?.lineWidth = linWidth
    }
    
    internal func animate() {
        let timer = Timer(timeInterval: 0.08, target: self, selector: #selector(rotate), userInfo: nil, repeats: true)
        self.timer = timer
        RunLoop.current.add(timer, forMode: RunLoop.Mode.default)
    }
    
    internal func stop() {
        timer = nil
    }
    
    @objc private func rotate() {
        let transform = CGAffineTransform(translationX: bounds.midX, y: bounds.midY).rotated(by: CGFloat(2).radians).translatedBy(x: -bounds.midX, y: -bounds.midY)
        path?.apply(transform)
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        tintColor.setStroke()
        path?.stroke()
    }
}

extension CGFloat {
    fileprivate var radians: CGFloat {
        return (self * .pi) / 180.0
    }
}
