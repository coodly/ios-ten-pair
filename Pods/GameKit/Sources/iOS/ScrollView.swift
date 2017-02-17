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

public class ScrollView: View, UIScrollViewDelegate {
    private lazy var scrollView: ShadowScrollView = {
        let scroll = ShadowScrollView()
        scroll.attached = self
        return scroll
    }()
    
    override internal var backingView: PlatformView {
        return scrollView
    }
    
    public var verticallyCentered = false
    public var contentInset: EdgeInsets = .zero {
        didSet {
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset
        }
    }
    private var contentWidthConstraint: LayoutConstraint?
    private var contentHeightConstraint: LayoutConstraint?
    
    private var inflated = false
    
    private var contained: ScrollViewContained? {
        didSet {
            oldValue?.backingView.removeFromSuperview()
            oldValue?.removeFromParent()
            
            guard let contained = contained else {
                return
            }
            
            addSubview(contained)
            
            let xCentered = LayoutConstraint(item: contained, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
            let topAligned = LayoutConstraint(item: contained, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
            contentWidthConstraint = LayoutConstraint(item: contained, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 0)
            contentHeightConstraint = LayoutConstraint(item: contained, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 0)
            
            addConstraints([xCentered, topAligned, contentWidthConstraint!, contentHeightConstraint!])
        }
    }
    
    public func present(_ contained: ScrollViewContained) {
        self.contained = contained
        contained.scrollView = self
    }
    
    public func setContentOffset(_ offset: CGPoint, animated: Bool) {
        scrollView.setContentOffset(offset, animated: animated)
    }
    
    public func contentSizeChanged(to size: CGSize, presentationHeight: CGFloat = 0) {
        let presentedContentSize = CGSize(width: size.width, height: presentationHeight > 0 ? presentationHeight : size.height)
        scrollView.contentSize = presentedContentSize
        contentWidthConstraint?.constant = size.width
        contentHeightConstraint?.constant = size.height
        
        guard !CGSize.zero.equalTo(self.size) else {
            return
        }
        
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
    }
    
    public override func positionChildren() {
        guard let contained = contained else {
            return
        }

        if verticallyCentered {
            adjustVerticalInsets()
        }
        
        contained.presentationWidth = size.width

        let visible = scrollView.convert(scrollView.bounds, to: contained.backingView)
        let combined = visible.intersection(contained.backingView.bounds)
        var inNodeSpace = combined
        inNodeSpace.origin.y = contained.backingView.bounds.height - combined.size.height - combined.origin.y
        let notify = SKAction.run {
            contained.scrolledVisible(to: inNodeSpace)
        }
        run(notify)
    }
    
    private func adjustVerticalInsets() {
        let spacing = max(0, (scrollView.bounds.height - contentHeightConstraint!.constant) / 2)
        guard scrollView.contentInset.top != spacing else {
            return
        }

        scrollView.contentInset = UIEdgeInsets(top: spacing, left: 0, bottom: spacing, right: 0)
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
    }
}
