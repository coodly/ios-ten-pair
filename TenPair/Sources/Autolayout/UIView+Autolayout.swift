import UIKit

extension UIView {
  public func pinToSuperviewEdges() {
    guard let parent = superview else {
      return
    }

    translatesAutoresizingMaskIntoConstraints = false
    topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
    bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
    leadingAnchor.constraint(equalTo: parent.leadingAnchor).isActive = true
    trailingAnchor.constraint(equalTo: parent.trailingAnchor).isActive = true
  }
}
