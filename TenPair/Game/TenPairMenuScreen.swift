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
import UIKit
import SpriteKit

let AppStoreID = 837173458

class TenPairMenuScreen: GameMenuScreen {
    var restartGameAction: SKAction?
    var showResumeOption = true
    
    override func loadContent() {
        super.loadContent()
        
        name = "TenPairMenuScreen"
        
        color = TenPairTheme.currentTheme.backgroundColor!.colorWithAlphaComponent(0.95)
        
        if showResumeOption {
            addMenuItem(menuItemWithTitle(NSLocalizedString("menu.option.resume", comment: ""), action:SKAction.runBlock({ () -> Void in
                self.game!.dismissScreen(self)
            })))
        }
        addMenuItem(menuItemWithTitle(NSLocalizedString("menu.option.restart", comment: ""), action:SKAction.runBlock({ () -> Void in
            self.game!.dismissScreen(self)
            self.runAction(self.restartGameAction!)
        })))
        addMenuItem(menuItemWithTitle(NSLocalizedString("menu.option.rate", comment: ""), action:SKAction.runBlock({ () -> Void in
            _ = UIApplication.sharedApplication().openURL(NSURL(string: "itms-apps://itunes.apple.com/app/id\(AppStoreID)")!)
        })))
        addMenuItem(menuItemWithTitle(NSLocalizedString("manu.option.send.message", comment: ""), action:SKAction.runBlock({ () -> Void in
            self.game!.sendEmail("contact@coodly.com", subject: "TenPair feedback")
        })))
    }
    
    func menuItemWithTitle(title: String, action: SKAction) -> TenPairMenuButton {
        let item = TenPairMenuButton()
        item.color = SKColor.redColor()
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            item.size = CGSizeMake(250, 44)
            item.titleFontSize = 20
        } else {
            item.size = CGSizeMake(400, 66)
            item.titleFontSize = 30
        }
        
        item.setTitle(title)
        item.color = TenPairTheme.currentTheme.menuOptionBackgroundColor!
        item.action = action
        item.zPosition = 3
        
        return item
    }
}