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

open class Game: SKScene {
    open func start() {
        
    }
    
    public func dismiss(_ sceeen: Screen) {
        sceeen.backingView.removeFromSuperview()
        sceeen.removeFromParent()
        topScreen()?.viewDidAppear()
    }
    
    public func dismissAll(upTo screen: Screen) {
        let screens = children.filter({ $0 is Screen}).sorted(by: { $0.zPosition > $1.zPosition })
        for dismissed in screens {
            if screen == dismissed {
                break
            }
            
            dismiss(dismissed as! Screen)
        }
    }
    
    public func present(screen: Screen) {
        topScreen()?.viewWillDisappear()
        screen.delayedAppear = children.count != 0
        screen.game = self
        add(fullSized: screen)
    }
    
    private func add(fullSized view: View) {
        view.zPosition = CGFloat(self.view?.subviews.count ?? 0) * CGFloat(100)
        view.anchorPoint = .zero
        view.position = .zero
        view.size = size
        addChild(view)
        let reference = view.backingView
        self.view!.add(fullSized: reference)

        view.inflate()
        view.applyTheme()
    }
    
    open override func update(_ currentTime: TimeInterval) {
        for c in children {
            guard let view = c as? View else {
                continue
            }
            
            view.update(currentTime)
        }
    }
    
    public func applyTheme() {
        for child in children {
            guard let screen = child as? Screen else {
                continue
            }
            
            screen.applyTheme()
        }
    }
    
    private func topScreen() -> Screen? {
        let screens = children.filter({ $0 is Screen })
        return screens.sorted(by: { $0.zPosition > $1.zPosition }).first as? Screen
    }
}
