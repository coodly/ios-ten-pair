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
        contained.anchorPoint = .zero
        contentSize = contained.size
        addChild(contained)
        
        contained.load()
        positionPresentedNode()
    }

    internal func positionPresentedNode() {
        guard let contained = contained else {
            return
        }
        
        let offset = contentOffsetY
        let nextPosition = CGPoint(x: (size.width - contained.size.width) / 2, y: -contained.size.height + size.height + offset)
        
        let moveAction = SKAction.move(to: nextPosition, duration: 0)
        
        let sequence = SKAction.sequence([moveAction])
        contained.run(sequence)
    }
}