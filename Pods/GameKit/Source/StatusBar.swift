/*
 * Copyright 2016 Coodly LLC
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

private extension DateFormatter {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
}

private extension Selector {
    static let updateTime = #selector(StatusBar.updateTime)
}

public class StatusBar: GameView {
    private var clockLabel: SKLabelNode!
    private var timer: Timer?
    public var tintColor: SKColor = .black {
        didSet {
            clockLabel.fontColor = tintColor
        }
    }
    
    public override func loadContent() {
        clockLabel = SKLabelNode(text: "12:30")
        clockLabel.fontColor = tintColor
        clockLabel.fontName = "Copperplate-Bold"
        clockLabel.fontSize = 20
        addChild(clockLabel)
        
        updateTime()
        
        timer?.invalidate()
        let seconds = Date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 60)
        let fireAt = Date(timeIntervalSinceNow: 60 - seconds)
        timer = Timer(fireAt: fireAt, interval: 60, target: self, selector: .updateTime, userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    public override func unloadContent() {
        timer?.invalidate()
    }
    
    public override func positionContent() {
        clockLabel.position = CGPoint(x: size.width / 2, y: (size.height - clockLabel.frame.size.height) / 2)
        super.positionContent()
    }
    
    @objc fileprivate func updateTime() {
        clockLabel.text = DateFormatter.timeFormatter.string(from: Date())
    }
}
