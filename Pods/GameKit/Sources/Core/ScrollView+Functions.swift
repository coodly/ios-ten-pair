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

public extension ScrollView {
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
