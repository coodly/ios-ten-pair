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

import SpriteKitUI
import SpriteKit

class WinScreen: Screen {
    private lazy var emitter: SKEmitterNode = {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Bundle.main.path(forResource: "Confetti", ofType: "sks")!) as! SKEmitterNode
    }()
    
    override func load() {
        addChild(emitter)
    }
    
    override func positionChildren() {
        emitter.position = CGPoint(x: size.width / 2, y: size.height + 20)
        emitter.particlePositionRange = CGVector(dx: size.width, dy: 0)
        emitter.particleBirthRate = size.width / 10
    }
    
    override func set(color: SKColor, for attribute: Appearance.Attribute) {
        super.set(color: color, for: attribute)
        
        if attribute == .foreground {
            emitter.particleColor = color
        }
    }
}
