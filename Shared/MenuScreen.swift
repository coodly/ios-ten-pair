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

class MenuScreen: SpriteKitUI.MenuScreen {
    var includeResume = true
    var restartHandler: ((StartField) -> ())?
    internal var gdprCheck: GDPRCheck?
    
    private var themeButton: MenuButton?
    private var feedbackButton: MenuButton?
    
    override var itemSize: CGSize {
        let buttonWidth = min(size.width - 80, 400)
        let buttonHeight = round(buttonWidth / 6)
        return CGSize(width: buttonWidth, height: buttonHeight)
    }
    
    override func load() {
        if AppConfig.current.statusBar && false {
            let statusBar = StatusBar()
            add(toTop: statusBar, height: 20)
        }
        
        if includeResume {
            let resume = button(named: NSLocalizedString("menu.option.resume", comment: ""))
            append(resume)
            resume.action = SKAction.run {
                [weak self] in
                
                guard let me = self else {
                    return
                }
                
                me.dismiss(me)
            }
        }
        
        let restartButton = button(named: NSLocalizedString("menu.option.restart", comment: ""))
        restartButton.action = SKAction.run {
            [weak self] in
            
            self?.showRestartOptions()
        }
        append(restartButton)
        
        let theme = Theme.current()
        let title = String(format: NSLocalizedString("menu.option.theme.base", comment: ""), theme.localizedName)
        let themeButton = button(named: title)
        self.themeButton = themeButton
        themeButton.action = SKAction.run() {
            [weak self] in
            
            self?.switchToNextTheme()
        }
        append(themeButton)
                
        if AppConfig.current.withFeedback {
            let hasMessage = FeedbackService.hasMessage()
            let title = hasMessage ? NSLocalizedString("menu.option.message.from", comment: "") : NSLocalizedString("menu.option.send.message", comment: "")
            
            feedbackButton = button(named: title)
            feedbackButton?.action = SKAction.run {
                [weak self] in
            
                self?.presentFeedback()
            }
            
            append(feedbackButton!)
        }
        
        if gdprCheck?.showGDPRConsentMenuItem ?? false {
            let gdpr = button(named: NSLocalizedString("menu.option.gdpr", comment: ""))
            gdpr.action = SKAction.run(gdprCheck!.present)
            append(gdpr)
        }
    }
    
    override func positionChildren() {
        super.positionChildren()
        
        for b in allOptions {
            b.titleFontSize = itemSize.height / 2
        }
    }
    
    func button(named title: String) -> MenuButton {
        let button = MenuButton()
        button.name = title
        button.set(title: title)
        return button
    }
    
    private func switchToNextTheme() {
        let theme = Theme.next()
        theme.load()
        game?.applyTheme()
        
        let title = String(format: NSLocalizedString("menu.option.theme.base", comment: ""), theme.localizedName)
        themeButton?.set(title: title)
    }
    
    private func presentFeedback() {
        FeedbackService.present()
        feedbackButton?.set(title: NSLocalizedString("menu.option.send.message", comment: ""))
    }
    
    private func showRestartOptions() {
        let restart = RestartScreen()
        restart.restartHandler = restartHandler
        present(restart)
    }
}
