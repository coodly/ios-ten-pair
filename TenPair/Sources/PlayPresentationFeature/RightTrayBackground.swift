import UIKit

class RightTrayBackground: TrayBackground {
  override func makePath(in rect: CGRect) -> CGPath {
    let radius = rect.height / 2
    let path = CGMutablePath()
    path.move(to: CGPoint(x: rect.minX + radius, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
    path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.midY),
                radius: radius, startAngle: .pi / 2, endAngle: -.pi / 2, clockwise: false)
    path.closeSubpath()
    return path
  }
}
