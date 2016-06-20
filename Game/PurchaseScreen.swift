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

import SpriteKit
import GameKit
import StoreKit
import LaughingAdventure
import SWLogger

class PurchaseScreen: GameScreen, FullVersionHandler {
    private var scrollView: GameScrollView!
    var product: SKProduct!
    var purchaser: Purchaser!
    private var loadingScreen = TenPairLoadingScreen()
    
    deinit {
        Log.debug("")
    }
    
    override func loadContent() {
        super.loadContent()
        
        color = SKColor.whiteColor()
        
        scrollView = GameScrollView()
        
        let width = min(400, size.width - 20)
        let text = SKSpriteNode.multiLineLabel(NSLocalizedString("purchase.screen.sales.letter", comment: ""), font: "Copperplate", fontSize: 20, maxWidth: width)
        text.color = TenPairTheme.currentTheme.defaultNumberTileColor!
        
        let purchaseTitle = String.localizedStringWithFormat(NSLocalizedString("purchase.screen.purchase.button", comment: ""), product.formattedPrice())
        let purchase = TenPairMenuButton.menuItemWithTitle(purchaseTitle) {
            [unowned self] in
            
            self.game?.presentModalScreen(self.loadingScreen)
            self.purchaser.purchase(self.product)
        }
        purchase.size = CGSizeMake(width, 40)
        
        let restoreButton = TenPairMenuButton.menuItemWithTitle(NSLocalizedString("purchase.screen.restore.button", comment: "")) {
            [unowned self] in
            
            
            self.game?.presentModalScreen(self.loadingScreen)
            self.purchaser.restore()
        }
        restoreButton.size = CGSizeMake(width, 40)
        
        let backButton = TenPairMenuButton.menuItemWithTitle(NSLocalizedString("purchase.screen.back.button", comment: "")) {
            [unowned self] in
            
            self.dismiss()
        }
        backButton.size = CGSizeMake(width, 40)

        
        let content = Content()
        content.appendItem(text)
        content.appendItem(purchase)
        content.appendItem(restoreButton)
        content.appendItem(backButton)
        
        scrollView.present(content)
        
        addGameView(scrollView)
        
        purchaser.activeMonitor = self
    }
    
    override func unloadContent() {
        scrollView.scrollView.removeFromSuperview()
        purchaser.activeMonitor = nil
    }
    
    override func positionContent() {
        scrollView.size = size
        
        super.positionContent()
    }
}

extension PurchaseScreen: PurchaseMonitor {
    func purchase(result: PurchaseResult, forProduct identifier: String) {
        game?.dismissScreen(loadingScreen)
        
        guard identifier == FullVersionIdentifier else {
            return
        }
        
        if result == .Cancelled {
            return
        }
        
        if result == .Failure {
            let alert = AlertViewScreen()
            alert.message = NSLocalizedString("purchase.screen.failure.message", comment: "")
            alert.addAction("close") {

            }
            self.game?.presentModalScreen(alert)
            return
        }
        
        self.markFullVersionUnlocked()

        if result == .Restored {
            let alert = AlertViewScreen()
            alert.message = NSLocalizedString("purchase.screen.restored.message", comment: "")
            alert.addAction("close") {
                [unowned self] in
                
                self.game?.dismissScreen(self)
            }
            self.game?.presentModalScreen(alert)
            return
        }

        // .Success
        dismiss()
    }
}

//TODO jaanus: copy/paste from menu container
private class Content: GameScrollViewContained {
    var items: [SKSpriteNode] = []
    var maxWidth: CGFloat = 0
    let menuSpacing: CGFloat = 10
    
    func appendItem(item: SKSpriteNode) {
        item.anchorPoint = CGPointZero
        maxWidth = max(item.size.width, maxWidth)
        items.append(item)
        addChild(item)
    }
    
    #if os(iOS)
    private override func presentationInsets() -> UIEdgeInsets {
        return UIEdgeInsetsMake(20, 0, 0, 0)
    }
    #else
    private override func presentationInsets() -> NSEdgeInsets {
        return NSEdgeInsetsMake(20, 0, 0, 0)
    }
    #endif
    
    override func positionContent() {
        super.positionContent()
        
        var yOffset: CGFloat = 0
        for button in Array(items.reverse()) {
            let positionX = (maxWidth - button.size.width) / 2
            button.position = CGPointMake(positionX, yOffset)
            yOffset += button.size.height
            yOffset += menuSpacing
        }
        yOffset -= menuSpacing
        
        size = CGSizeMake(maxWidth, yOffset)
        scrollView!.contentSizeChanged()
    }
}
