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
import GameKit
import StoreKit
import LaughingAdventure
import SWLogger

private extension Selector {
    static let checkFullVersion = #selector(TenPairMenuScreen.checkFullVersion)
}

class TenPairMenuScreen: GameMenuScreen, FullVersionHandler, StorePresenter {
    var restartGameAction: SKAction?
    var showResumeOption = true
    var fullVersionProduct: SKProduct?
    var purchaser: Purchaser!
    fileprivate var purchaseButton: TenPairMenuButton!
    var sendFeedbackHandler: (() -> ())?
    
    deinit {
        Log.debug("")
    }
    
    override func loadContent() {
        super.loadContent()
        
        NotificationCenter.default.addObserver(self, selector: .checkFullVersion, name: NSNotification.Name(rawValue: CheckAppFullVersionNotification), object: nil)
        
        name = "TenPairMenuScreen"
        
        color = TenPairTheme.currentTheme.backgroundColor!.withAlphaComponent(0.95)
        
        if showResumeOption {
            addMenuItem(TenPairMenuButton.menuItemWithTitle(NSLocalizedString("menu.option.resume", comment: "")) {
                [unowned self] in
                
                self.dismiss()
            })
        }
        addMenuItem(TenPairMenuButton.menuItemWithTitle(NSLocalizedString("menu.option.restart", comment: "")) {
            [unowned self] in
            
            self.game!.run(self.restartGameAction!)
            self.dismiss()
        })
        purchaseButton = TenPairMenuButton.menuItemWithTitle(fullVersionMenuItemTitle()) {
            [unowned self] in

            self.tappedFullVersionButton()
        }
        if showFullVersionPurchase() {
            addMenuItem(purchaseButton)
        }
        addMenuItem(TenPairMenuButton.menuItemWithTitle(NSLocalizedString("menu.option.rate", comment: "")) {
            [unowned self] in
            
            self.openInStore()
        })
        if let feedbackClosure = sendFeedbackHandler {
            addMenuItem(TenPairMenuButton.menuItemWithTitle(NSLocalizedString("manu.option.send.message", comment: ""), closure: feedbackClosure))
        }
    }
    
    override func unloadContent() {
        super.unloadContent()
        
        NotificationCenter.default.removeObserver(self)
    }
        
    override func positionContent() {
        let buttons = allItems()
        let buttonWidth = min(size.width - 80, 400)
        let buttonHeight = round(buttonWidth / 6)
        for button in buttons {
            guard let menuButton = button as? TenPairMenuButton else {
                continue
            }
            
            menuButton.size = CGSize(width: buttonWidth, height: buttonHeight)
            menuButton.titleFontSize = round(buttonHeight / 2)
        }
        
        super.positionContent()
    }
    
    fileprivate func fullVersionMenuItemTitle() -> String {
        if  fullVersionUnlocked() {
            return NSLocalizedString("menu.option.full.version.purchased", comment: "")
        }
        
        if let product = fullVersionProduct {
            return String.localizedStringWithFormat(NSLocalizedString("menu.option.full.version.price.base", comment: ""), product.formattedPrice())            
        }

        return String.localizedStringWithFormat(NSLocalizedString("menu.option.full.version.price.base", comment: ""), "-")
    }
    
    fileprivate func tappedFullVersionButton() {
        if fullVersionUnlocked() {
            let alert = AlertViewScreen()
            alert.message = NSLocalizedString("menu.full.version.thanks.message", comment: "")
            alert.addAction("close") {

            }
            
            game?.presentModalScreen(alert)
            return
        }
        
        guard let purchase = fullVersionProduct else {
            let alert = AlertViewScreen()
            alert.message = NSLocalizedString("menu.full.version.no.price.message", comment: "")
            alert.addAction("close") {

            }
            
            game?.presentModalScreen(alert)
            return
        }
        
        let purchaseScreen = PurchaseScreen()
        purchaseScreen.product = purchase
        purchaseScreen.purchaser = purchaser
        game?.presentModalScreen(purchaseScreen)
    }
    
    @objc fileprivate func checkFullVersion() {
        purchaseButton.setTitle(fullVersionMenuItemTitle())
    }
}
