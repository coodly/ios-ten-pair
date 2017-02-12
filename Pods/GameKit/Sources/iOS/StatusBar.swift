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
    static let batteryLevelChanged = #selector(StatusBar.batteryLevelChanged(notification:))
}

private let BatteryRedLevel: CGFloat = 0.2

public class StatusBar: View {
    private var clockLabel: SKLabelNode!
    private var timer: Timer?
    public var tintColor: SKColor = .black {
        didSet {
            clockLabel.fontColor = tintColor
            batteryLevelBox.fillColor = tintColor
            batteryBox.strokeColor = tintColor
            
            updateBattery()
        }
    }
    private var batteryBox: SKShapeNode!
    private var batteryLevelBox: SKShapeNode!
    
    public override func load() {
        clockLabel = SKLabelNode(text: "12:30")
        clockLabel.fontColor = tintColor
        clockLabel.fontName = "Copperplate-Bold"
        clockLabel.fontSize = 20
        addChild(clockLabel)
        
        batteryLevelBox = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 25, height: 12), cornerRadius: 2)
        batteryLevelBox.strokeColor = .clear
        batteryLevelBox.fillColor = tintColor
        batteryLevelBox.zPosition = zPosition + 1
        addChild(batteryLevelBox)
        batteryBox = SKShapeNode()
        batteryBox.path = CGPath(roundedRect: CGRect(x: 0, y: 0, width: 25, height: 12), cornerWidth: 2, cornerHeight: 2, transform: nil)
        batteryBox.zPosition = zPosition + 2
        batteryBox.strokeColor = tintColor
        addChild(batteryBox)
        
        updateTime()
        updateBattery()
        
        timer?.invalidate()
        let seconds = Date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 60)
        let fireAt = Date(timeIntervalSinceNow: 60 - seconds)
        timer = Timer(fireAt: fireAt, interval: 60, target: self, selector: .updateTime, userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoopMode.defaultRunLoopMode)
        
        NotificationCenter.default.addObserver(self, selector: .batteryLevelChanged, name: Notification.Name.UIDeviceBatteryLevelDidChange, object: nil)
        UIDevice.current.isBatteryMonitoringEnabled = true
    }
    
    public override func unload() {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
        UIDevice.current.isBatteryMonitoringEnabled = false
    }
    
    override func sizeChanged() {
        super.sizeChanged()
        
        clockLabel.position = CGPoint(x: size.width / 2, y: (size.height - clockLabel.frame.size.height) / 2)
        let batteryPoint = CGPoint(x: size.width - batteryBox.frame.size.width - 4, y: (size.height - batteryBox.frame.size.height) / 2)
        batteryBox.position = batteryPoint
        batteryLevelBox.position = batteryPoint
    }
    
    @objc fileprivate func updateTime() {
        clockLabel.text = DateFormatter.timeFormatter.string(from: Date())
    }
    
    private func updateBattery() {
        let level = CGFloat(max(UIDevice.current.batteryLevel, 0.01))
        var levelBox = batteryBox.frame.insetBy(dx: 2, dy: 2)
        levelBox.size.width = levelBox.width * CGFloat(level)
        batteryLevelBox.fillColor = level <= BatteryRedLevel ? .red : tintColor
        batteryLevelBox.strokeColor = tintColor
        let fillPath = UIBezierPath(roundedRect: levelBox, byRoundingCorners: [UIRectCorner.bottomLeft, UIRectCorner.topLeft], cornerRadii: CGSize(width: 2, height: 2))
        batteryLevelBox.path = fillPath.cgPath
    }
    
    @objc fileprivate func batteryLevelChanged(notification: Notification) {
        updateBattery()
    }
    
    public override func set(_ color: SKColor, for attribute: Appearance.Attribute) {
        switch attribute {
        case Appearance.Attribute.foreground:
            tintColor = color
        default:
            break // no op
        }
    }
}
