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
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.delegate = self
        return scroll
    }()
    
    override internal var backingView: PlatformView {
        return scrollView
    }

    internal var contained: ScrollViewContained? {
        didSet {
            oldValue?.backingView.removeFromSuperview()
            oldValue?.removeFromParent()
            
            guard let contained = contained else {
                return
            }
            
            scrollView.addSubview(contained.backingView)
        }
    }
    internal var contentOffsetY: CGFloat {
        return scrollView.contentOffset.y
    }
    internal var contentSize: CGSize = .zero {
        didSet {
            scrollView.contentSize = contentSize
            
            if verticallyCentered {
                let spacing = max(0, (backingView.frame.size.height - contentSize.height) / 2)
                scrollView.contentInset = UIEdgeInsetsMake(spacing, 0, spacing, 0)
            }
            
            guard let containedBacking = contained?.backingView else {
                return
            }
            containedBacking.frame.origin.x = max(0, (scrollView.frame.width - containedBacking.frame.width) / 2)
            contained?.backingView.frame.size = contentSize
        }
    }
    public var contentInset: EdgeInsets = .zero {
        didSet {
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset
        }
    }
    public var verticallyCentered = false
    
    override func sizeChanged() {
        super.sizeChanged()
        
        positionPresentedNode()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        positionPresentedNode()
    }
    
    public override func set(color: SKColor, for attribute: Appearance.Attribute) {
        // no op
    }
}
