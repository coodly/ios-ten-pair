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
    private var contained: ScrollViewContained? {
        didSet {
            oldValue?.backingView.removeFromSuperview()
            oldValue?.removeFromParent()
            
            guard let contained = contained else {
                return
            }
            
            contained.color = .red
            contained.anchorPoint = .zero
            addChild(contained)
            contained.inflate()
            let backing = contained.backingView
            backing.translatesAutoresizingMaskIntoConstraints = false
            flipped.addSubview(backing)
            
            let topPinned = NSLayoutConstraint(item: backing, attribute: .top, relatedBy: .equal, toItem: flipped, attribute: .top, multiplier: 1, constant: 0)
            let centered = NSLayoutConstraint(item: backing, attribute: .centerX, relatedBy: .equal, toItem: flipped, attribute: .centerX, multiplier: 1, constant: 0)
            containedWidth = NSLayoutConstraint(item: backing, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 0)
            containedHeight = NSLayoutConstraint(item: backing, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
            flipped.addConstraints([topPinned, centered, containedWidth!, containedHeight!])
        }
    }
    private var containedWidth: NSLayoutConstraint?
    private var containedHeight: NSLayoutConstraint?
    
    @objc fileprivate func didScroll(notification: NSNotification) {
        guard let object = notification.object as? NSScrollView, scrollView === object else {
            return
        }
        
        positionContained()
    }
    
    public override func set(color: SKColor, for attribute: Appearance.Attribute) {
        // no op
    }
    
    public func present(_ contained: ScrollViewContained) {
        self.contained = contained
        contained.scrollView = self
    }
    
    public func contentSizeChanged(to size: CGSize, presentationHeight: CGFloat = 0) {
        containedWidth?.constant = size.width
        containedHeight?.constant = size.height
        flipped.frame.size.height = presentationHeight > 0 ? presentationHeight : size.height
        scrollView.layoutSubtreeIfNeeded()
        positionChildren()
    }
    
    public func setContentOffset(_ offset: CGPoint, animated: Bool) {
        scrollView.contentView.scroll(to: NSPoint(x: offset.x, y: offset.y))
        scrollView.reflectScrolledClipView(scrollView.contentView)
        positionContained()
    }
    
    public override func positionChildren() {
        flipped.frame.size.width = size.width
        contained?.presentationWidth = size.width
        positionContained()
    }
    
    private func positionContained() {
        guard let contained = contained else {
            return
        }
        
        let visible = scrollView.documentVisibleRect

        var position = contained.backingView.frame.origin
        position.y = visible.maxY - (containedHeight?.constant ?? 0)
        contained.position = position

        let inScroll = scrollView.convert(visible, from: flipped)
        
        let visibleInBacking = scrollView.convert(inScroll, to: contained.backingView)
        let combined = visibleInBacking.intersection(contained.backingView.bounds)
        let notify = SKAction.run {
            contained.scrolledVisible(to: combined)
        }
        run(notify)
    }
}

private class Flipper: NSView {
    override var isFlipped: Bool {
        return true
    }
}
