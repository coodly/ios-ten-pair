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

import Foundation
import GameKit
import SpriteKit

private let TopMenuBarHeight: CGFloat = 50

class PlayScreen: Screen {
    private var statusBar: TopMenuBar!
    private var scrollView: ScrollView!
    
    override func load() {
        color = .red
        
        scrollView = ScrollView()
        add(fullSized: scrollView)
        
        let field = NumbersField()
        field.size = CGSize(width: 200, height: 20000)
        scrollView.contentInset = EdgeInsetsMake(TopMenuBarHeight + 10, 0, 0, 0)
        scrollView.present(field)
        
        statusBar = TopMenuBar()
        add(toTop: statusBar, height: TopMenuBarHeight)
        
        statusBar.menuButton?.action = SKAction.run {
            [weak self] in
            
            Log.debug("Present menu screen")
            
            let menu = MenuSceen()
            menu.color = SKColor.white.withAlphaComponent(0.95)
            self?.present(menu)
        }
        
        statusBar.reloadButton?.action = SKAction.run {
            print("Reload")
        }
    }
}
