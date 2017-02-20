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
    internal var itemSpacing: CGFloat = 0 {
        didSet {
            if oldValue == itemSpacing {
                return
            }
            
            stackView.spacing = itemSpacing
            adjustStackSize()
        }
    }
    internal var itemSize: CGSize = .zero {
        didSet {
            if oldValue == itemSize {
                return
            }
            
            stackView.frame.size.width = itemSize.width
            
            guard heightConstraints.count > 0 else {
                return
            }
            
            for height in heightConstraints {
                height.constant = itemSize.height
            }
            
            adjustStackSize()
        }
    }
    private var heightConstraints = [NSLayoutConstraint]()

    private lazy var stackView: UIStackView = {
        let stack = ShadowStackView()
        stack.attached = self
        stack.axis = .vertical
        return stack
    }()
    
    override var backingView: PlatformView {
        return stackView
    }
    
    override func addSubview(_ view: View) {
        view.anchorPoint = .zero
        let backing = view.backingView
        backing.translatesAutoresizingMaskIntoConstraints = false
        let height = NSLayoutConstraint(item: backing, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: itemSize.height)
        height.priority = UILayoutPriorityDefaultHigh
        stackView.addArrangedSubview(backing)
        stackView.addConstraint(height)
        heightConstraints.append(height)
        addChild(view)
        
        adjustStackSize()
    }
    
    private func adjustStackSize() {
        let height = CGFloat(heightConstraints.count) * itemSize.height + CGFloat(heightConstraints.count - 1) * itemSpacing
        scrollView?.contentSizeChanged(to: CGSize(width: itemSize.width, height: height))
    }
}
