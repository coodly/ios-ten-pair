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
    public var contentInset: EdgeInsets = NSEdgeInsetsZero
    internal var presentationInset: EdgeInsets = NSEdgeInsetsZero {
        didSet {
            scrollView.contentInsets = presentationInset

            var presentedHeight = contained!.size.height
            let insets = contained!.presentationInsets()
            presentedHeight += insets.top
            presentedHeight += insets.bottom
            presentedHeight += contentInset.bottom
            flipped.frame.size.height = presentedHeight
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
    
    public override func positionChildren() {
        super.positionChildren()
        
        contained?.presentationWidth = size.width
        
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
    
    internal func scroll(to point: CGPoint, animated: Bool) {
        let saneYOffset = min(point.y, flipped.bounds.height - scrollView.bounds.height)
        let to = CGPoint(x: 0, y: saneYOffset)
        scrollView.contentView.scroll(to: to)
        scrollView.reflectScrolledClipView(scrollView.contentView)
        positionPresentedNode()
    }
    
    public func present(_ contained: ScrollViewContained) {
        self.contained = contained
        contained.scrollView = self
        contained.anchorPoint = .zero
        contentSize = contained.size
        addChild(contained)
        
        contained.inflate()
        positionPresentedNode()
    }
    
    internal func positionPresentedNode() {
        guard let contained = contained else {
            return
        }
        
        let offset = contentOffsetY
        let nextPosition = CGPoint(x: (size.width - contained.size.width) / 2, y: -contained.size.height + size.height + offset)
        
        let moveAction = SKAction.move(to: nextPosition, duration: 0)
        
        let notifyAction = SKAction.run() {
            let bottomPoint = self.translatePointToContent(CGPoint(x: 0, y: 0))
            let topPoint = self.translatePointToContent(CGPoint(x: 0, y: self.size.height))
            
            var visible = CGRect.zero
            visible.origin = CGPoint(x: 0, y: bottomPoint.y)
            visible.size = CGSize(width: self.contained!.size.width, height: topPoint.y - bottomPoint.y)
            
            var bounds = CGRect.zero
            bounds.size = self.contained!.size
            
            let intersection = visible.intersection(bounds)
            
            // Sanity check on macOS. Exiting fullscreen gave invalid intersection
            if CGSize.zero.equalTo(intersection.size) {
                return
            }
            
            self.contained!.scrolledVisible(to: intersection)
        }
        
        let sequence = SKAction.sequence([moveAction, notifyAction])
        contained.run(sequence)
    }
    
    private func translatePointToContent(_ point: CGPoint) -> CGPoint {
        return contained!.convert(point, from: parent!)
    }
    
    public func contentSizeChanged() {
        var insets = contentInset
        let presentationInset = contained!.presentationInsets()
        
        insets.top += presentationInset.top
        insets.bottom += presentationInset.bottom
        insets.left += presentationInset.left
        insets.right += presentationInset.right
        
        self.presentationInset = insets
        
        positionPresentedNode()
    }
    
    public func setContentOffset(_ offset: CGPoint, animated: Bool) {
        let saneYOffset = max(offset.y, 0)
        scroll(to: CGPoint(x: offset.x, y: saneYOffset), animated: animated)
    }
}

private class Flipper: NSView {
    override var isFlipped: Bool {
        return true
    }
}
