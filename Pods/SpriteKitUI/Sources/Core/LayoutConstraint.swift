/*
 * Copyright 2017 Coodly LLC
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

public class LayoutConstraint {
    internal let wrapped: NSLayoutConstraint
    internal var constant: CGFloat {
        get {
            return wrapped.constant
        }
        
        set {
            wrapped.constant = newValue
        }
    }
    
    public convenience init(item view1: View, attribute attr1: LayoutAttribute, relatedBy relation: LayoutRelation, toItem view2: View?, attribute attr2: LayoutAttribute, multiplier: CGFloat, constant c: CGFloat) {
        
        let wrapped = NSLayoutConstraint(item: view1.backingView, attribute: attr1, relatedBy: relation, toItem: view2?.backingView, attribute: attr2, multiplier: multiplier, constant: c)
        self.init(wrapped: wrapped)
    }

    public init(wrapped: NSLayoutConstraint) {
        self.wrapped = wrapped
    }

    public class func constraints(withVisualFormat format: String, options opts: LayoutFormatOptions = [], metrics: Metrics = [:], views: [String : Any]) -> [LayoutConstraint] {
        
        
        var withBacking = [String: Any]()
        for (key, value) in views {
            guard let view = value as? View else {
                withBacking[key] = value
                continue
            }
            
            withBacking[key] = view.backingView
        }
        
        let constraints = NSLayoutConstraint.constraints(withVisualFormat: format, options: opts, metrics: metrics, views: withBacking)
        return constraints.map({ LayoutConstraint(wrapped: $0) })
    }
}
