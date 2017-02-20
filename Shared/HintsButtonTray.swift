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

class HintsButtonTray: View {
    var button: HintButton?
    
    override func load() {
        borderWidth = 1
        
        let button = HintButton()
        self.button = button
        button.set(icon: "hint")
        addSubview(button)

        let width = LayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 44)
        let height = LayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 44)
        let xCenter = LayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        let yCenter = LayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        
        addConstraints([width, height, xCenter, yCenter])
    }
    
    override func set(color: SKColor, for attribute: Appearance.Attribute) {
        super.set(color: color, for: attribute)
        
        if attribute == .foreground {
            borderColor = color
        }
    }
}

class HintButton: Button {
    
}
