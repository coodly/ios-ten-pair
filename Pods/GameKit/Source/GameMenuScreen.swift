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

open class GameMenuScreen: GameScreen {
    let scrollView = GameScrollView()
    let container = GameMenuPresentationContainer()
    var menuItemsSpacing = 10
    var numberOfItems = 0
    var menuYOffset: CGFloat = 0
    public var statusBar: StatusBar? {
        didSet {
            guard let added = statusBar else {
                return
            }
            addGameView(added)
        }
    }
    
    public var allItems: [GameMenuButton] {
        return container.items
    }

    open override func loadContent() {
        scrollView.size = size
        scrollView.yCenterContent = true
        addGameView(scrollView)
        
        container.anchorPoint = CGPoint.zero
        scrollView.present(container)
    }
    
    open override func positionContent() {
        container.size = size
        scrollView.size = size
        if let bar = statusBar {
            bar.position = CGPoint(x: 0, y: size.height - bar.size.height)
            bar.size.width = size.width
        }
        
        super.positionContent()
    }
    
    open func add(_ item: GameMenuButton) {
        container.append(item)
    }
    
    override open func unloadContent() {
        scrollView.scrollView.removeFromSuperview()
        
        super.unloadContent()
    }
}
