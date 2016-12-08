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
import GameKit

class ActionButtonsTray: SlideOutButtonsTray {
    fileprivate(set) var hintButton: Button!
    
    override func loadContent() {
        super.loadContent()
        
        color = TenPairTheme.currentTheme.defaultNumberTileColor!
        
        openButton = buttonWithImage("arrow")
        addChild(openButton)

        appendButton(buttonWithImage("info"))
        appendButton(buttonWithImage("undo"))
        hintButton = buttonWithImage("hint")
        appendButton(hintButton)
    }
    
    fileprivate func buttonWithImage(_ named: String) -> Button {
        let result = Button(imageNamed: named)
        result.size = CGSize(width: 44, height: 44)
        
        return result
    }
}
