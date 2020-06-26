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
    private lazy var scene = WinScene(size: view.bounds.size)
    private var timer: Timer? {
        didSet {
            oldValue?.invalidate()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.color(hexString: "#121212").withAlphaComponent(0.9)
        
        view.addSubview(sceneView)
        sceneView.pinToSuperviewEdges()
        sceneView.backgroundColor = .clear
        
        scene.scaleMode = .aspectFill
        scene.backgroundColor = .clear
        sceneView.presentScene(scene)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(tap)
    }
    
    @objc fileprivate func tapped() {
        dismiss(animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            
        scene.emit()
        
        let timer = Timer(timeInterval: 0.5, target: scene, selector: #selector(WinScene.emit), userInfo: nil, repeats: true)
        self.timer = timer
        RunLoop.current.add(timer, forMode: RunLoop.Mode.default)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        timer = nil
    }
}

private class WinScene: SKScene {
    @objc func emit() {
        let point = size.randomPoint()
        addChild(explosion(at: point))
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

extension CGSize {
    fileprivate func randomPoint() -> CGPoint {
        let minX = width / 4
        let minY = height / 4
        let randomX = CGFloat.random(in: minX..<(minX * 3))
        let randomY = CGFloat.random(in: minY..<(minY * 3))
        return CGPoint(x: randomX, y: randomY)
    }
}
