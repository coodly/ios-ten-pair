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

public class GameMenuScreen: GameScreen {
    let scrollView = GameScrollView()
    let container = GameMenuPresentationContainer()
    var menuItemsSpacing = 10
    var numberOfItems = 0
    var menuYOffset: CGFloat = 0
    
    public override func loadContent() {
        scrollView.size = size
        scrollView.yCenterContent = true
        addGameView(scrollView)
        
        container.anchorPoint = CGPointZero
        scrollView.present(container)
    }
    
    public override func positionContent() {
        scrollView.size = size
    }
    
    public func addMenuItem(item: GameMenuButton) {
        container.appendItem(item)
    }
    
    override func unloadContent() {
        scrollView.scrollView.removeFromSuperview()
    }
}