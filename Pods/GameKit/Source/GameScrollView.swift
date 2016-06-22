/*
* Copyright 2015 Coodly LLC
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

import Foundation
import SpriteKit

public class GameScrollView: GameView {
    #if os(iOS)
    public var scrollView = UIScrollView(frame: CGRectZero)
    public var contentInset = UIEdgeInsetsZero
    #else
    public lazy var scrollView: NSScrollView = {
        let view = NSScrollView(frame: CGRectZero)
        view.drawsBackground = false
        view.hasVerticalScroller = true
        view.automaticallyAdjustsContentInsets = false
        view.autoresizingMask = [.ViewWidthSizable, .ViewHeightSizable]
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: .scrolled, name: NSScrollViewDidLiveScrollNotification, object: nil)
        
        return view
    }()
    public var contentInset = NSEdgeInsetsZero
    private lazy var dummy: NSView = {
        var dummy = Flipper(frame: CGRectZero)
        dummy.wantsLayer = true
        self.scrollView.documentView = dummy
        return dummy
    }()
    #endif
    var presented: GameScrollViewContained?
    var yCenterContent = false
    
    override public func loadContent() {
        name = "GameScrollView"
        positionScrollView()
    }
    
    public func present(content: GameScrollViewContained) {
        addGameView(content)

        presented = content
        presented!.scrollView = self
        adjustContentSize()
        
        #if os(iOS)
        #else
            scrollView.contentView.scrollToPoint(NSMakePoint(0, -contentInset.top))
        #endif
        
        positionPresentedNode()
    }
    
    override public func positionContent() {
        positionPresentedNode()
        
        super.positionContent()
    }
    
    func positionPresentedNode() {
        let offset = contentOffsetY()
        let nextPosition = CGPointMake((size.width - presented!.size.width) / 2, -presented!.size.height + size.height + offset)
        
        let moveAction = SKAction.moveTo(nextPosition, duration: 0)
        
        let notifyAction = SKAction.runBlock() {
            let bottomPoint = self.translatePointToContent(CGPointMake(0, 0))
            let topPoint = self.translatePointToContent(CGPointMake(0, self.size.height))
            
            var visible = CGRectZero
            visible.origin = CGPointMake(0, bottomPoint.y)
            visible.size = CGSizeMake(self.presented!.size.width, topPoint.y - bottomPoint.y)
            
            var bounds = CGRectZero
            bounds.size = self.presented!.size
            
            let intersection = CGRectIntersection(visible, bounds)
            
            self.presented!.scrolledVisibleTo(intersection)
        }

        let sequence = SKAction.sequence([moveAction, notifyAction])
        presented!.runAction(sequence)
    }
    
    public func contentSizeChanged() {
        adjustContentSize()
        
        var insets = contentInset
        let presentationInset = presented!.presentationInsets()
        
        insets.top += presentationInset.top
        insets.bottom += presentationInset.bottom
        insets.left += presentationInset.left
        insets.right += presentationInset.right
        
        var performScroll = false
        if (yCenterContent) {
            let yOffset = (size.height - presented!.size.height) / 2
            insets.top = yOffset
            insets.bottom = yOffset
            performScroll = true
        }
        
        #if os(iOS)
            scrollView.contentInset = insets
        #else
            scrollView.contentInsets = insets
            if performScroll {
                scrollView.contentView.scrollToPoint(NSMakePoint(0, -insets.top))
            }
        #endif
        
        positionPresentedNode()
    }
    
    public func translatePointToContent(point: CGPoint) -> CGPoint {
        return presented!.convertPoint(point, fromNode: parent!)
    }
    
    public func setContentOffset(contentOffset: CGPoint, animated: Bool) {
        var saneYOffset = max(contentOffset.y, 0)
        #if os(iOS)
            saneYOffset = min(saneYOffset, scrollView.contentSize.height - scrollView.bounds.height)
        #else
            saneYOffset = min(saneYOffset, dummy.bounds.height - scrollView.bounds.height)
        #endif
        scroll(CGPointMake(0, saneYOffset), animated: animated)
    }
}

#if os(iOS)
    import UIKit
    
    extension GameScrollView: UIScrollViewDelegate {
        public func scrollViewDidScroll(scrollView: UIScrollView) {
            positionPresentedNode()
        }
        
        func positionScrollView() {
            scrollView.frame = scene!.view!.bounds
            scrollView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(contentInset.top, 0, contentInset.bottom, 0)
            scene!.view!.addSubview(scrollView)
            scrollView.delegate = self
        }
        
        func contentOffsetY() -> CGFloat {
            return scrollView.contentOffset.y
        }
        
        func contentSize() -> CGSize {
            return presented!.size
        }
        
        func adjustContentSize() {
            scrollView.contentSize = contentSize()
        }
        
        func scroll(to: CGPoint, animated: Bool) {
            scrollView.setContentOffset(to, animated: animated)
        }
    }
#else
    private extension Selector {
        static let scrolled = #selector(GameScrollView.didScroll(_:))
    }
    
    extension GameScrollView {
        @objc private func didScroll(notification: NSNotification) {
            guard let object = notification.object as? NSScrollView where scrollView === object else {
                return
            }
            
            positionPresentedNode()
        }

        func positionScrollView() {
            scrollView.frame = scene!.view!.bounds
            scrollView.contentInsets = contentInset
            
            scene!.view!.addSubview(scrollView)
        }
        
        func contentOffsetY() -> CGFloat {
            return scrollView.contentView.visibleRect.origin.y
        }
        
        func contentSize() -> NSSize {
            return presented!.size
        }

        func adjustContentSize() {
            var presentedHeight = contentSize().height
            let insets = presented!.presentationInsets()
            presentedHeight += insets.top
            presentedHeight += insets.bottom
            presentedHeight += contentInset.bottom
            dummy.frame = CGRectMake(0, 0, self.size.width, presentedHeight)
        }
        
        func scroll(to: CGPoint, animated: Bool) {
            scrollView.contentView.scrollToPoint(to)
            scrollView.reflectScrolledClipView(scrollView.contentView)
            positionPresentedNode()
        }
    }
    
    private class Flipper: NSView {
        override var flipped: Bool {
            return true
        }
    }
#endif
