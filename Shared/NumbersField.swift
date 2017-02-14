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
import GameKit

private let NumberOfColumns = 9
private let SidesSpacing: CGFloat = 10 * 2

class NumbersField: ScrollViewContained {
    var presentedNumbers: [Int] = []
    
    private var tileSize = CGSize.zero
    
    override var presentationWidth: CGFloat {
        didSet {
            if oldValue == presentationWidth {
                return
            }
            
            let tileWidth = (presentationWidth - SidesSpacing) / CGFloat(NumberOfColumns)
            let maxWidth = CGFloat(AppConfig.current.maxTileWidth)
            let rounded = min(round(tileWidth), maxWidth)
            let nextSize = CGSize(width: rounded, height: rounded)
            
            if nextSize.equalTo(tileSize) {
                return
            }
        }
    }
    
    override func load() {
        color = .blue
    }
    
    override func set(color: SKColor, for attribute: Appearance.Attribute) {
        
    }
}
