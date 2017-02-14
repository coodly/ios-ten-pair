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

import SpriteKit

internal class MenuOptionsContainer: ScrollViewContained {
    internal var itemSpacing: CGFloat = 10 {
        didSet {
            stackView.spacing = itemSpacing
        }
    }
    internal var itemSize: CGSize = .zero {
        didSet {
            stackView.frame.size.width = itemSize.width
            size.width = itemSize.width
        }
    }
    
    private lazy var stackView: NSStackView = {
        let stack = ShadowStackView()
        stack.attached = self
        stack.orientation = .vertical
        return stack
    }()
    
    override var backingView: PlatformView {
        return stackView
    }
    
    override func addSubview(_ view: View) {
        view.anchorPoint = .zero
        let backing = view.backingView
        backing.translatesAutoresizingMaskIntoConstraints = false
        backing.heightAnchor.constraint(equalToConstant: itemSize.height).isActive = true
        stackView.addArrangedSubview(backing)
        
        let left = NSLayoutConstraint(item: backing, attribute: .left, relatedBy: .equal, toItem: stackView, attribute: .left, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: backing, attribute: .right, relatedBy: .equal, toItem: stackView, attribute: .right, multiplier: 1, constant: 0)
        stackView.addConstraints([left, right])
        
        addChild(view)
        
        stackView.frame.size = stackView.fittingSize
        size.height = stackView.frame.height
    }
}
