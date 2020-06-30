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

extension UIView {
    internal func pinToSuperviewEdges() {
        guard let parent = superview else {
            return
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
        leadingAnchor.constraint(equalTo: parent.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: parent.trailingAnchor).isActive = true
    }
    
    internal class func viewNib(_ bundle: Bundle? = nil) -> UINib {
        let name = className
        return UINib(nibName: name, bundle: bundle)
    }
    
    internal class var className: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    internal class func identifier() -> String {
        return className
    }
    
    public static func loadInstance() -> Self {
        return viewNib(Bundle(for: Self.self)).instantiate(withOwner: nil, options: nil).first as! Self
    }
    
    internal func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-10, 10, -10, 10, -5, 5, -3, 3, 0]
        layer.add(animation, forKey: "shake")
    }
}
