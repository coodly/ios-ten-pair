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

class TenPairWinScreen: TenPairMenuScreen {
    var emitter: SKEmitterNode?
    
    override func loadContent() {
        showResumeOption = false

        let fireworks = NSKeyedUnarchiver.unarchiveObject(withFile: Bundle.main.path(forResource: "WinAnimation", ofType: "sks")!) as! SKEmitterNode
        emitter = fireworks
        fireworks.particleBirthRate = size.width / 10
        fireworks.targetNode = scene
        addChild(fireworks)
        super.loadContent()
        positionContent()
    }
    
    override func positionContent() {
        super.positionContent()
        emitter!.position = CGPoint(x: size.width / 2, y: size.height / 2)
        emitter!.particlePositionRange = CGVector(dx: size.width, dy: size.height)
    }
}
