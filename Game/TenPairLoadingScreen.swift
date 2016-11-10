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
import GameKit

class TenPairLoadingScreen : GameLoadingView {
    var spinner: SKShapeNode?
    var lastUpdateTime: TimeInterval = 0
    
    override func loadContent() {
        if let _ = self.spinner {
            return
        }
        
        color = TenPairTheme.currentTheme.backgroundColor!.withAlphaComponent(0.8)
        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: 0, y: 0), radius: 50, startAngle: radians(0), endAngle: radians(310), clockwise: false)
        let spinner = SKShapeNode()
        self.spinner = spinner
        spinner.path = path 
        spinner.strokeColor = TenPairTheme.currentTheme.tintColor!
        spinner.lineWidth = 10
        addChild(spinner)
    }
    
    override func positionContent() {
        spinner!.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        super.positionContent()
    }
    
    override func update(_ time: TimeInterval) {
        if lastUpdateTime < 1 {
            lastUpdateTime = time
            return
        }
        
        let change = time - lastUpdateTime
        spinner!.zRotation = spinner!.zRotation - CGFloat(change * 2.0)
        lastUpdateTime = time
    }
}
