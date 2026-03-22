import UIKit

public class TrayBackground: UIView {
  private let shapeLayer = CAShapeLayer()
  private let borderLayer = CAShapeLayer()
  private var glassView: UIVisualEffectView?
  private let maskLayer = CAShapeLayer()
  
  @objc public dynamic var fillColor: UIColor = .systemBackground {
    didSet { setNeedsLayout() }
  }
  
  @objc public dynamic var strokeColor: UIColor = .label {
    didSet { setNeedsLayout() }
  }
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  private func setup() {
    if #available(iOS 26, *) {
      let glass = UIVisualEffectView(effect: UIGlassEffect(style: .regular))
      glass.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      insertSubview(glass, at: 0)
      glassView = glass
      layer.mask = maskLayer
    } else {
      layer.addSublayer(shapeLayer)
      layer.addSublayer(borderLayer)
      registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _: UITraitCollection) in
        self.setNeedsLayout()
      }
    }
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    let path = makePath(in: bounds)
    
    if #available(iOS 26, *) {
      glassView?.frame = bounds
      maskLayer.path = path
    } else {
      shapeLayer.path = path
      shapeLayer.fillColor = fillColor.cgColor
      
      borderLayer.path = path
      borderLayer.fillColor = UIColor.clear.cgColor
      borderLayer.strokeColor = strokeColor.cgColor
      borderLayer.lineWidth = 1
    }
  }
  
  public override func didMoveToWindow() {
    super.didMoveToWindow()
    setNeedsLayout()
  }

  func makePath(in rect: CGRect) -> CGPath {
    fatalError("Subclasses must implement makePath(in:)")
  }
  
}
