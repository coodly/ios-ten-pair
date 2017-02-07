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

internal extension NativeShadowed where Self: NSView {
    func positionTied() {
        guard let superview = superview else {
            return
        }
        
        let parentFrame = superview.bounds
        var myPosition = CGPoint.zero
        myPosition.x = frame.origin.x
        myPosition.y = parentFrame.height - bounds.height
        
        tied.position = myPosition
        tied.size = bounds.size
        
        for sub in subviews {
            guard sub.subviews.count == 0, let view = sub as? NativeShadowed else {
                continue
            }
            
            view.positionTied()
        }
    }
}
