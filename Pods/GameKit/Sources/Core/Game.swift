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
    }
    
    public func present(screen: Screen) {
        screen.delayedAppear = children.count != 0
        add(fullSized: screen)
    }
    
    private func add(fullSized view: View) {
        view.game = self
        view.zPosition = CGFloat(self.view?.subviews.count ?? 0) * CGFloat(100)
        view.anchorPoint = .zero
        view.position = .zero
        view.size = size
        addChild(view)
        let reference = view.backingView
        self.view!.add(fullSized: reference)

        view.inflate()
        view.applyTheme()
        triggerUpdate()
    }
    
    open override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        triggerUpdate()
    }
    
    open override func didChangeSize(_ oldSize: CGSize) {
        triggerUpdate()
    }
    
    private func triggerUpdate() {
        // let autolayout finish
        DispatchQueue.main.async {
            for child in self.children {
                guard let view = child as? View else {
                    continue
                }
                
                view.sizeChanged()
            }
        }
    }
}
