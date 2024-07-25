import UIKit

extension UIView {
  public func shake() {
    let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
    animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
    animation.duration = 0.6
    animation.values = [-10, 10, -10, 10, -5, 5, -3, 3, 0]
    layer.add(animation, forKey: "shake")
  }
}
