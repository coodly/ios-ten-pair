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
import SpriteKitUI
import SpriteKit

private let TopMenuBarHeight: CGFloat = 50
private let ActionButtonsTrayHeight: CGFloat = 50

class PlayScreen: Screen {
    private var statusBar: TopMenuBar!
    private var scrollView: ScrollView!
    
    override func load() {
        color = .red
                
        scrollView = ScrollView()
        scrollView.name = "Play scroll view"
        add(fullSized: scrollView)
        
        let field = NumbersField()
        field.presentedNumbers = FieldSave.load()
        field.name = "Numbers field"
        scrollView.contentInset = EdgeInsetsMake(TopMenuBarHeight + 10, 0, 10 + ActionButtonsTrayHeight + 10, 0)
        scrollView.present(field)
        
        statusBar = TopMenuBar()
        statusBar.name = "Top menu bar"
        add(toTop: statusBar, height: TopMenuBarHeight)
        
        field.statusView = statusBar.statusView
        field.updateFieldStatus()
        
        let restartAction = SKAction.run {
            field.presentedNumbers = DefaultStartBoard
            field.restart()
        }
        
        statusBar.menuButton?.action = SKAction.run {
            [weak self] in
            
            Log.debug("Present menu screen")
            
            let menu = MenuScreen()
            
            menu.restartAction = SKAction.run {
                [unowned menu] in
                
                self?.dismiss(menu)
                self?.execute(restartAction)
            }
            
            self?.present(menu)
        }
        
        statusBar.reloadButton?.action = SKAction.run {
            [weak self] in
            
            Log.debug("Field reload")

            let reload = SKAction.run() {
                field.reload()
            }
            
            self?.execute(reload)
        }
        
        let findMatchAction = SKAction.run {
            field.searchForMatch() {
                result in
                
                switch result {
                case .foundOnScreen:
                    //no op
                    break
                case .notFound:
                    //TODO jaanus: shake the field
                    break
                case .foundOffScreen(let offset):
                    let scrollTo = offset - self.scrollView!.size.height / 2
                    self.scrollView!.setContentOffset(CGPoint(x: 0, y: scrollTo), animated: true)
                }
            }
        }
        
        let hintsTray = HintsButtonTray()
        addSubview(hintsTray)
        hintsTray.button?.action = SKAction.run {
            self.execute(findMatchAction)
        }
        
        let views: [String: AnyObject] = ["hints": hintsTray]
        
        let vertical = LayoutConstraint.constraints(withVisualFormat: "V:[hints(\(ActionButtonsTrayHeight))]-(10)-|", options: [], metrics: nil, views: views)
        let horizontal = LayoutConstraint.constraints(withVisualFormat: "H:|[hints(\(ActionButtonsTrayHeight))]", options: [], metrics: nil, views: views)
        
        addConstraints(vertical + horizontal)
    }
    
    private func execute(_ task: SKAction) {
        execute([task])
    }
    
    private func execute(_ tasks: [SKAction]) {
        let loading = LoadingScreen()
        present(loading)
        let wait = SKAction.wait(forDuration: 1)
        let dismiss = SKAction.run {
            self.dismiss(loading)
        }
        var executed = [SKAction]()
        executed.append(wait)
        executed.append(contentsOf: tasks)
        executed.append(dismiss)
        let actions = SKAction.sequence(executed)
        run(actions)
    }
}
