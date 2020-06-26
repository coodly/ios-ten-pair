/*
 * Copyright 2020 Coodly LLC
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

import UIKit
import SpriteKit

internal class WinViewController: UIViewController, StoryboardLoaded {
    private lazy var sceneView = SKView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(sceneView)
        sceneView.pinToSuperviewEdges()
        sceneView.backgroundColor = .clear
        
        let scene = WinScene(size: view.bounds.size)
        scene.scaleMode = .aspectFill
        scene.backgroundColor = .clear
        sceneView.presentScene(scene)
    }
}

private class WinScene: SKScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let point = touch.location(in: self)
            addChild(explosion(at: point))
        }
    }
    
    private func explosion(at point: CGPoint) -> SKEmitterNode {
        let emitter = NSKeyedUnarchiver.unarchiveObject(withFile: Bundle.main.path(forResource: "Fireworks", ofType: "sks")!) as! SKEmitterNode
        emitter.position = point
        emitter.zPosition = 2
        emitter.particleColor = [
            SKColor(red: 0.353, green: 0.784, blue: 0.980, alpha: 1),
            SKColor.white,
            SKColor(red: 1, green: 105.0 / 255.0, blue: 180.0 / 255.0, alpha: 1)].randomElement()!
        return emitter
    }
}
