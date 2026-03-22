import UIKit

public class LeftTrayBackground: TrayBackground {
  public override func makePath(in rect: CGRect) -> CGPath {
    let radius = rect.height / 2
    let path = CGMutablePath()
    path.move(to: CGPoint(x: rect.minX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
    path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.midY),
                radius: radius, startAngle: -.pi / 2, endAngle: .pi / 2, clockwise: false)
    path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
    path.closeSubpath()
    return path
  }
}
