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

open class GameScrollView: GameView {
    #if os(iOS)
    open var scrollView = UIScrollView(frame: CGRect.zero)
    open var contentInset = UIEdgeInsets.zero
    #else
    public lazy var scrollView: NSScrollView = {
        let view = NSScrollView(frame: .zero)
        view.drawsBackground = false
        view.hasVerticalScroller = true
        view.automaticallyAdjustsContentInsets = false
        view.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
    
        NotificationCenter.default.addObserver(self, selector: .scrolled, name: NSNotification.Name.NSScrollViewDidLiveScroll, object: nil)
        
        return view
    }()
    public var contentInset = NSEdgeInsetsZero
    fileprivate lazy var dummy: NSView = {
        var dummy = Flipper(frame: .zero)
        dummy.wantsLayer = true
        self.scrollView.documentView = dummy
        return dummy
    }()
    #endif
    var presented: GameScrollViewContained?
    var yCenterContent = false
    
    override open func loadContent() {
        name = "GameScrollView"
        positionScrollView()
    }
    
    open func present(_ content: GameScrollViewContained) {
        addGameView(content)

        presented = content
        presented!.scrollView = self
        adjustContentSize()
        
        #if os(iOS)
        #else
            scrollView.contentView.scroll(to: NSMakePoint(0, -contentInset.top))
        #endif
        
        positionPresentedNode()
    }
    
    override open func positionContent() {
        positionPresentedNode()
        
        super.positionContent()
    }
    
    func positionPresentedNode() {
        let offset = contentOffsetY()
        let nextPosition = CGPoint(x: (size.width - presented!.size.width) / 2, y: -presented!.size.height + size.height + offset)
        
        let moveAction = SKAction.move(to: nextPosition, duration: 0)
        
        let notifyAction = SKAction.run() {
            let bottomPoint = self.translatePointToContent(CGPoint(x: 0, y: 0))
            let topPoint = self.translatePointToContent(CGPoint(x: 0, y: self.size.height))
            
            var visible = CGRect.zero
            visible.origin = CGPoint(x: 0, y: bottomPoint.y)
            visible.size = CGSize(width: self.presented!.size.width, height: topPoint.y - bottomPoint.y)
            
            var bounds = CGRect.zero
            bounds.size = self.presented!.size
            
            let intersection = visible.intersection(bounds)
            
            // Sanity check on macOS. Exiting fullscreen gave invalid intersection
            if CGSize.zero.equalTo(intersection.size) {
                return
            }
            
            self.presented!.scrolledVisibleTo(intersection)
        }

        let sequence = SKAction.sequence([moveAction, notifyAction])
        presented!.run(sequence)
    }
    
    open func contentSizeChanged() {
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
                scrollView.contentView.scroll(to: NSMakePoint(0, -insets.top))
            }
        #endif
        
        positionPresentedNode()
    }
    
    open func translatePointToContent(_ point: CGPoint) -> CGPoint {
        return presented!.convert(point, from: parent!)
    }
    
    open func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        var saneYOffset = max(contentOffset.y, 0)
        #if os(iOS)
            saneYOffset = min(saneYOffset, scrollView.contentSize.height - scrollView.bounds.height)
            scroll(CGPoint(x: 0, y: saneYOffset), animated: animated)
        #else
            saneYOffset = min(saneYOffset, dummy.bounds.height - scrollView.bounds.height)
            scroll(to: CGPoint(x: 0, y: saneYOffset), animated: animated)
        #endif
    }
}

#if os(iOS)
    import UIKit
    
    extension GameScrollView: UIScrollViewDelegate {
        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            positionPresentedNode()
        }
        
        func positionScrollView() {
            scrollView.frame = scene!.view!.bounds
            scrollView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
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
        
        func scroll(_ to: CGPoint, animated: Bool) {
            scrollView.setContentOffset(to, animated: animated)
        }
    }
#else
    private extension Selector {
        static let scrolled = #selector(GameScrollView.didScroll(notification:))
    }
    
    extension GameScrollView {
        @objc fileprivate func didScroll(notification: NSNotification) {
            guard let object = notification.object as? NSScrollView, scrollView === object else {
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
            dummy.frame = CGRect(x: 0, y: 0, width: self.size.width, height: presentedHeight)
        }
        
        func scroll(to: CGPoint, animated: Bool) {
            scrollView.contentView.scroll(to: to)
            scrollView.reflectScrolledClipView(scrollView.contentView)
            positionPresentedNode()
        }
    }
    
    private class Flipper: NSView {
        override var isFlipped: Bool {
            return true
        }
    }
#endif
