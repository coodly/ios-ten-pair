import UIKit

public class SpinnerView: UIView {
    private var path: UIBezierPath?
    private var timer: Timer? {
        didSet {
            oldValue?.invalidate()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let linWidth = CGFloat(15)
        let used = bounds.insetBy(dx: linWidth / 2, dy: linWidth / 2)
        path = UIBezierPath(arcCenter: CGPoint(x: used.midX, y: used.midY), radius: used.width / 2, startAngle: CGFloat(0).radians, endAngle: CGFloat(310).radians, clockwise: true)
        path?.lineCapStyle = .round
        path?.lineWidth = linWidth
    }
    
    public func animate() {
        let timer = Timer(timeInterval: 0.08, target: self, selector: #selector(rotate), userInfo: nil, repeats: true)
        self.timer = timer
        RunLoop.current.add(timer, forMode: RunLoop.Mode.default)
    }
    
    public func stop() {
        timer = nil
    }
    
    @objc private func rotate() {
        let transform = CGAffineTransform(translationX: bounds.midX, y: bounds.midY).rotated(by: CGFloat(2).radians).translatedBy(x: -bounds.midX, y: -bounds.midY)
        path?.apply(transform)
        setNeedsDisplay()
    }
    
    public override func draw(_ rect: CGRect) {
        tintColor.setStroke()
        path?.stroke()
    }
}

extension CGFloat {
    fileprivate var radians: CGFloat {
        return (self * .pi) / 180.0
    }
}
