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
    weak var attached: View? { get set }
}

internal extension ShadowingView where Self: PlatformView {
    func positionAttached() {
        guard let parent = superview, let attached = attached else {
            return
        }
        
        let parentFrame = parent.bounds
        var myPosition = CGPoint.zero
        myPosition.x = frame.origin.x
        myPosition.y = InFlippedEnv ? frame.minY : parentFrame.height - frame.maxY
        
        attached.position = myPosition
        attached.size = bounds.size
        
        attached.positionChildren()
        attached.revealHidded()
        
        for sub in subviews {
            sub.layout()
        }
    }
}

internal class ShadowView: NSView, ShadowingView {
    weak var attached: View?
    weak var mouseDelelegate: MouseDelegate?
    
    override func layout() {
        super.layout()
        
        positionAttached()
    }
    
    override func mouseDown(with event: NSEvent) {
        let location = convert(event.locationInWindow, from: nil)
        mouseDelelegate?.touchDown(at: location)
    }
}

internal class ShadowButton: NSButton, ShadowingView {
    weak var attached: View?
    
    override func layout() {
        super.layout()
        
        positionAttached()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
    }

}

internal class ShadowScrollView: NSScrollView, ShadowingView {
    weak var attached: View?
    
    override func layout() {
        super.layout()
        
        positionAttached()
    }
}

internal class ShadowStackView: NSStackView, ShadowingView {
    weak var attached: View?
    
    override func layout() {
        super.layout()
        
        positionAttached()
    }
}
