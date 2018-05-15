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

let TopMenuBarHeight: CGFloat = 50
let ActionButtonsTrayHeight: CGFloat = 50

class PlayScreen: Screen {
    private var statusBar: TopMenuBar!
    private var scrollView: ScrollView!
    private var numbersField: NumbersField?
    private var hintsTray: ButtonTray?
    private var undoTray: ButtonTray?
    
    override func load() {
        color = .red
                
        scrollView = ScrollView()
        scrollView.name = "Play scroll view"
        add(fullSized: scrollView)
        
        let field = NumbersField()
        numbersField = field
        field.presentedNumbers = FieldSave.load()
        field.name = "Numbers field"
        scrollView.present(field)
        
        let topBackground = TopMenuBackground()
        topBackground.name = "Top menu background"
        addSubview(topBackground)
        
        statusBar = TopMenuBar()
        statusBar.name = "Top menu bar"
        addSubview(statusBar)
        
        let statusLeading = LayoutConstraint(item: statusBar, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let statusTrailing = LayoutConstraint(item: statusBar, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
        let statusHeight = LayoutConstraint(item: statusBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: TopMenuBarHeight)
        let top: LayoutConstraint
        if #available(iOS 11, *) {
            top = LayoutConstraint(wrapped: statusBar.topAnchor.constraint(equalTo: safeAreaLayoutTopAnchor))
        } else {
            top = LayoutConstraint(item: statusBar, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 20)
        }
        addConstraints([statusLeading, statusTrailing, statusHeight, top])
        
        let topBackgroundTop = LayoutConstraint(item: topBackground, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let topBackgroundLeft = LayoutConstraint(item: topBackground, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let topBackgroundRight = LayoutConstraint(item: topBackground, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
        let topBackgroundBottom = LayoutConstraint(item: topBackground, attribute: .bottom, relatedBy: .equal, toItem: statusBar, attribute: .bottom, multiplier: 1, constant: 0)
        addConstraints([topBackgroundTop, topBackgroundLeft, topBackgroundRight, topBackgroundBottom])

        
        field.statusView = statusBar.statusView
        field.updateFieldStatus()
        
        statusBar.menuButton?.action = SKAction.run {
            [weak self] in
            
            Log.debug("Present menu screen")
            
            self?.presentMenu()
        }
        
        statusBar.reloadButton?.action = SKAction.run {
            [weak self] in
            
            Log.debug("Field reload")

            let reload = SKAction.run() {
                field.reload()
                NotificationCenter.default.post(name: .fieldReload, object: nil)
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
                    let tileSize = self.numbersField!.tileSize
                    let tileRect = CGRect(x: 0, y: offset, width: tileSize.width, height: tileSize.height)
                    self.scrollView!.scrollRectToVisible(tileRect, animated: true)
                }
                
                switch result {
                case .foundOnScreen, .foundOffScreen(_):
                    NotificationCenter.default.post(name: .hintTaken, object: nil)
                default:
                    break
                }
            }
        }
        
        let wonAction = SKAction.run {
            [weak self] in
            
            self?.presentWin()
        }
        
        field.gameWonAction = wonAction
        
        let hintsTray = ButtonTray()
        self.hintsTray = hintsTray
        hintsTray.iconName = "hint"
        addSubview(hintsTray)
        hintsTray.button?.action = SKAction.run {
            self.execute(findMatchAction)
        }
        
        let hintsLeading = LayoutConstraint(item: hintsTray, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        let hintsWidth = LayoutConstraint(item: hintsTray, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: ActionButtonsTrayHeight)
        let hintsHeight = LayoutConstraint(item: hintsTray, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: ActionButtonsTrayHeight)
        let hintsBottom = LayoutConstraint(wrapped: hintsTray.bottomAnchor.constraint(equalTo: safeAreaLayoutBottomAnchor))
        addConstraints([hintsLeading, hintsWidth, hintsHeight, hintsBottom])
        
        let undoTray = ButtonTray()
        self.undoTray = undoTray
        undoTray.iconName = "Undo"
        addSubview(undoTray)
        undoTray.button?.action = SKAction.run {
            Log.debug("Undo")
        }
        
        let undoTrailing = LayoutConstraint(item: undoTray, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        let undoWidth = LayoutConstraint(item: undoTray, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: ActionButtonsTrayHeight)
        let undoHeight = LayoutConstraint(item: undoTray, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: ActionButtonsTrayHeight)
        let undoBottom = LayoutConstraint(wrapped: undoTray.bottomAnchor.constraint(equalTo: safeAreaLayoutBottomAnchor))
        addConstraints([undoTrailing, undoWidth, undoHeight, undoBottom])
    }
    
    override func positionChildren() {
        super.positionChildren()
        
        DispatchQueue.main.async {
            let top = self.frame.size.height - self.statusBar.frame.minY + 10
            let bottom = (self.hintsTray?.frame.maxY ?? 0) + 10
            
            guard self.scrollView.contentInset.top < 1 else {
                return
            }
            
            self.scrollView.contentInset = EdgeInsetsMake(top, 0, bottom, 0)
            self.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 10, height: 10), animated: false)
        }
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
    
    private func presentMenu(withResume: Bool = true, extraDismissed: Screen? = nil) {
        let menu = MenuScreen()
        menu.includeResume = withResume
        menu.restartHandler = {
            [weak self]
            
            option in
            
            guard let me = self else {
                return
            }
            
            me.dismissAll(upTo: me)
            me.restart(using: option)
        }
        
        present(menu)
    }
    
    private func restart(using: StartField) {
        scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 10, height: 10), animated: true)
        let fill = SKAction.run {
            let field: [Int]
            switch using {
            case .regular:
                field = DefaultStartBoard
            case .random(let lines):
                let tiles = lines * NumberOfColumns
                var numbers = [Int]()
                for _ in 0..<tiles {
                    numbers.append(Int(arc4random_uniform(10)))
                }
                field = numbers
            }
            
            self.numbersField?.presentedNumbers = field
            self.numbersField?.restart()
        }
        
        execute(fill)
    }
    
    private func presentWin() {
        let win = WinScreen()
        present(win)
        let wait = SKAction.wait(forDuration: 2)
        let show = SKAction.run {
            self.presentMenu(withResume: false, extraDismissed: win)
        }
        
        run(SKAction.sequence([wait, show]))
    }
}
