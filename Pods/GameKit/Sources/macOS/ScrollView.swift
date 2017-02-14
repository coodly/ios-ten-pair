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

private extension Selector {
    static let scrolled = #selector(ScrollView.didScroll(notification:))
}

public class ScrollView: View {
    private var widthConstraint: NSLayoutConstraint?
    override var backingView: PlatformView {
        return scrollView
    }
    internal var contained: ScrollViewContained? {
        didSet {
            oldValue?.backingView.removeFromSuperview()
            oldValue?.removeFromParent()
            
            guard let contained = contained else {
                return
            }
            
            let sub = contained.backingView
            flipped.addSubview(sub)
            
            contained.backingView.translatesAutoresizingMaskIntoConstraints = false
            let top = NSLayoutConstraint(item: sub, attribute: .top, relatedBy: .equal, toItem: flipped, attribute: .top, multiplier: 1, constant: 0)
            let centered = NSLayoutConstraint(item: sub, attribute: .centerX, relatedBy: .equal, toItem: flipped, attribute: .centerX, multiplier: 1, constant: 0)
            let width = NSLayoutConstraint(item: sub, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 100)
            let bottom = NSLayoutConstraint(item: sub, attribute: .bottom, relatedBy: .equal, toItem: flipped, attribute: .bottom, multiplier: 1, constant: 0)
            flipped.addConstraints([top, centered, bottom, width])
            
            width.constant = sub.frame.width
            widthConstraint = width
        }
    }
    
    internal var contentOffsetY: CGFloat {
        return scrollView.contentView.visibleRect.origin.y
    }
    private lazy var scrollView: NSScrollView = {
        let view = ShadowScrollView(frame: .zero)
        view.attached = self
        view.drawsBackground = false
        view.hasVerticalScroller = true
        view.automaticallyAdjustsContentInsets = false
        view.documentView = self.flipped
        
        NotificationCenter.default.addObserver(self, selector: .scrolled, name: NSNotification.Name.NSScrollViewDidLiveScroll, object: nil)
        
        return view
    }()
    internal var contentSize: CGSize = .zero {
        didSet {
            widthConstraint?.constant = contentSize.width
            flipped.frame.size.height = contentSize.height
        }
    }
    public var contentInset: EdgeInsets = NSEdgeInsetsZero {
        didSet {
            scrollView.contentInsets = contentInset
        }
    }
    public var verticallyCentered = false
    private lazy var flipped: Flipper = {
        var dummy = Flipper(frame: .zero)
        dummy.wantsLayer = true
        return dummy
    }()
    
    @objc fileprivate func didScroll(notification: NSNotification) {
        guard let object = notification.object as? NSScrollView, scrollView === object else {
            return
        }
        
        positionPresentedNode()
    }
    
    override func sizeChanged() {
        super.sizeChanged()
        
        if let contained = contained {
            widthConstraint?.constant = contained.size.width
            flipped.frame.size.height = contained.size.height
        }
        flipped.frame.size.width = size.width
        
        if verticallyCentered {
            let spacing = max(0, (backingView.frame.size.height - contentSize.height) / 2)
            scrollView.contentInsets = EdgeInsetsMake(spacing, 0, spacing, 0)
        }

        positionPresentedNode()
    }
    
    public override func set(color: SKColor, for attribute: Appearance.Attribute) {
        // no op
    }
}

private class Flipper: NSView {
    override var isFlipped: Bool {
        return true
    }
}
