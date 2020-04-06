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

internal protocol ShadowingView {
    var attached: View? { get set }
    
    func extraOffset() -> CGPoint
}

internal extension ShadowingView where Self: PlatformView {
    func positionAttached() {
        guard let parent = superview, let attached = attached else {
            return
        }
        
        let parentFrame = parent.bounds
        var myPosition = CGPoint.zero
        myPosition.x = frame.origin.x
        myPosition.y = InFlippedEnv ? frame.minY : parentFrame.height - frame.maxY + extraOffset().y
        
        attached.position = myPosition
        attached.size = bounds.size
        
        attached.positionChildren()
        attached.revealHidded()

        for sub in subviews {
            sub.setNeedsLayout()
        }
    }
    
    func extraOffset() -> CGPoint {
        return .zero
    }
}

internal class ShadowView: UIView, ShadowingView {
    weak var attached: View?
    
    override func layoutSubviews() {
        super.layoutSubviews()

        positionAttached()
    }
}

internal class ShadowButton: UIButton, ShadowingView {
    weak var attached: View?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        positionAttached()
    }
}

internal class ShadowScrollView: UIScrollView, ShadowingView {
    weak var attached: View?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        positionAttached()
    }
    
    func extraOffset() -> CGPoint {
        return contentOffset
    }
}

internal class ShadowStackView: UIStackView, ShadowingView {
    weak var attached: View?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        positionAttached()
    }
}
