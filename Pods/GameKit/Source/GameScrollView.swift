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
import UIKit

public class GameScrollView: GameView, UIScrollViewDelegate {
    var scrollView = UIScrollView(frame: CGRectZero)
    var presented: GameScrollViewContained?
    public var contentInset = UIEdgeInsetsZero
    var yCenterContent = false
    
    override public func loadContent() {
        name = "GameScrollView"
        scrollView.frame = scene!.view!.bounds
        scrollView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(contentInset.top, 0, contentInset.bottom, 0)
        scene!.view!.addSubview(scrollView)
        scrollView.delegate = self
    }
    
    public func present(content: GameScrollViewContained) {
        addGameView(content)

        presented = content
        presented!.scrollView = self
        scrollView.contentSize = content.size
        
        positionPresentedNode()
    }
    
    override public func positionContent() {
        positionPresentedNode()
        
        super.positionContent()
    }
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        positionPresentedNode()
    }
    
    func positionPresentedNode() {
        let offset = scrollView.contentOffset.y
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
        scrollView.contentSize = presented!.size
        
        var insets = contentInset
        let presentationInset = presented!.presentationInsets()
        
        insets.top += presentationInset.top
        insets.bottom += presentationInset.bottom
        insets.left += presentationInset.left
        insets.right += presentationInset.right
        
        if (yCenterContent) {
            let yOffset = (size.height - presented!.size.height) / 2
            insets.top = yOffset
            insets.bottom = yOffset
        }
        
        scrollView.contentInset = insets
        
        positionPresentedNode()
    }
    
    public func translatePointToContent(point: CGPoint) -> CGPoint {
        return presented!.convertPoint(point, fromNode: parent!)
    }
    
    public func setContentOffset(contentOffset: CGPoint, animated: Bool) {
        var saneYOffset = max(contentOffset.y, 0)
        saneYOffset = min(saneYOffset, scrollView.contentSize.height - scrollView.bounds.height)
        scrollView.setContentOffset(CGPointMake(0, saneYOffset), animated: animated)
    }
}