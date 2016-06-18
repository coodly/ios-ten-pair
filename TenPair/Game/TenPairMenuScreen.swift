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
import GameKit
import StoreKit
import LaughingAdventure

let AppStoreID = 837173458

class TenPairMenuScreen: GameMenuScreen {
    var restartGameAction: SKAction?
    var showResumeOption = true
    var fullVersionProduct: SKProduct?
    var purchaser: Purchaser!
    
    override func loadContent() {
        super.loadContent()
        
        name = "TenPairMenuScreen"
        
        color = TenPairTheme.currentTheme.backgroundColor!.colorWithAlphaComponent(0.95)
        
        if showResumeOption {
            addMenuItem(TenPairMenuButton.menuItemWithTitle(NSLocalizedString("menu.option.resume", comment: "")) {
                self.game!.dismissScreen(self)
            })
        }
        addMenuItem(TenPairMenuButton.menuItemWithTitle(NSLocalizedString("menu.option.restart", comment: "")) {
            self.game!.dismissScreen(self)
            self.game!.runAction(self.restartGameAction!)
        })
        addMenuItem(TenPairMenuButton.menuItemWithTitle(fullVersionMenuItemTitle()) {
            self.tappedFullVersionButton()
        })
        addMenuItem(TenPairMenuButton.menuItemWithTitle(NSLocalizedString("menu.option.rate", comment: "")) {
            _ = UIApplication.sharedApplication().openURL(NSURL(string: "itms-apps://itunes.apple.com/app/id\(AppStoreID)")!)
        })
        addMenuItem(TenPairMenuButton.menuItemWithTitle(NSLocalizedString("manu.option.send.message", comment: "")) {
            self.game!.sendEmail("contact@coodly.com", subject: "TenPair feedback")
        })
    }
        
    override func positionContent() {
        let buttons = allItems()
        let buttonWidth = min(size.width - 80, 400)
        let buttonHeight = round(buttonWidth / 6)
        for button in buttons {
            guard let menuButton = button as? TenPairMenuButton else {
                continue
            }
            
            menuButton.size = CGSizeMake(buttonWidth, buttonHeight)
            menuButton.titleFontSize = round(buttonHeight / 2)
        }
        
        super.positionContent()
    }
    
    private func fullVersionMenuItemTitle() -> String {
        if  fullVersionUnlocked() {
            return NSLocalizedString("menu.option.full.version.purchased", comment: "")
        }
        
        if let product = fullVersionProduct {
            return String.localizedStringWithFormat(NSLocalizedString("menu.option.full.version.price.base", comment: ""), product.formattedPrice())            
        }

        return String.localizedStringWithFormat(NSLocalizedString("menu.option.full.version.price.base", comment: ""), "-")
    }
    
    private func tappedFullVersionButton() {
        if fullVersionUnlocked() {
            let alert = AlertViewScreen()
            alert.message = NSLocalizedString("menu.full.version.thanks.message", comment: "")
            alert.addAction("close") {
                self.game?.dismissScreen(alert)
            }
            
            self.game?.presentModalScreen(alert)
            return
        }
        
        if let purchase = fullVersionProduct {
            let purchaseScreen = PurchaseScreen()
            purchaseScreen.product = purchase
            purchaseScreen.purchaser = purchaser
            game?.presentModalScreen(purchaseScreen)
            return
        }
    }
    
    private func fullVersionUnlocked() -> Bool {
        return false
    }
}
