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

class PurchaseScreen: Screen, FullVersionHandler {
    fileprivate var scrollView: ScrollView!
    var product: SKProduct!
    var purchaser: Purchaser!
    fileprivate var loadingScreen = TenPairLoadingScreen()
    
    deinit {
        Log.debug("")
    }
    
    override func loadContent() {
        super.loadContent()
        
        color = SKColor.white
        
        scrollView = ScrollView()
        
        let width = min(400, size.width - 20)
        let text = SKSpriteNode.multiLineLabel(NSLocalizedString("purchase.screen.sales.letter", comment: ""), font: "Copperplate", fontSize: 20, maxWidth: width)
        text.color = TenPairTheme.currentTheme.defaultNumberTileColor!
        
        let purchaseTitle = String.localizedStringWithFormat(NSLocalizedString("purchase.screen.purchase.button", comment: ""), product.formattedPrice())
        let purchase = TenPairMenuButton.menuItemWithTitle(purchaseTitle) {
            [unowned self] in
            
            self.game?.presentModal(screen: self.loadingScreen)
            self.purchaser.purchase(self.product)
        }
        purchase.size = CGSize(width: width, height: 40)
        
        let restoreButton = TenPairMenuButton.menuItemWithTitle(NSLocalizedString("purchase.screen.restore.button", comment: "")) {
            [unowned self] in
            
            
            self.game?.presentModal(screen: self.loadingScreen)
            self.purchaser.restore()
        }
        restoreButton.size = CGSize(width: width, height: 40)
        
        let backButton = TenPairMenuButton.menuItemWithTitle(NSLocalizedString("purchase.screen.back.button", comment: "")) {
            [unowned self] in
            
            self.dismiss()
        }
        backButton.size = CGSize(width: width, height: 40)

        
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
    func purchaseResult(_ result: PurchaseResult, for identifier: String) {
        game?.dismiss(loadingScreen)
        
        guard identifier == FullVersionIdentifier else {
            return
        }
        
        if result == .cancelled {
            return
        }
        
        if result == .failure {
            let alert = AlertViewScreen()
            alert.message = NSLocalizedString("purchase.screen.failure.message", comment: "")
            alert.addAction("close") {

            }
            self.game?.presentModal(screen: alert)
            return
        }
        
        self.markFullVersionUnlocked()

        if result == .restored {
            let alert = AlertViewScreen()
            alert.message = NSLocalizedString("purchase.screen.restored.message", comment: "")
            alert.addAction("close") {
                [unowned self] in
                
                self.game?.dismiss(self)
            }
            self.game?.presentModal(screen: alert)
            return
        }

        // .Success
        dismiss()
    }
}

//TODO jaanus: copy/paste from menu container
private class Content: ScrollViewContained {
    var items: [SKSpriteNode] = []
    var maxWidth: CGFloat = 0
    let menuSpacing: CGFloat = 10
    
    func appendItem(_ item: SKSpriteNode) {
        item.anchorPoint = CGPoint.zero
        maxWidth = max(item.size.width, maxWidth)
        items.append(item)
        addChild(item)
    }
    
    #if os(iOS)
    fileprivate override func presentationInsets() -> UIEdgeInsets {
        return UIEdgeInsetsMake(20, 0, 0, 0)
    }
    #else
    fileprivate override func presentationInsets() -> EdgeInsets {
        return NSEdgeInsetsMake(20, 0, 0, 0)
    }
    #endif
    
    override func positionContent() {
        super.positionContent()
        
        var yOffset: CGFloat = 0
        for button in Array(items.reversed()) {
            let positionX = (maxWidth - button.size.width) / 2
            button.position = CGPoint(x: positionX, y: yOffset)
            yOffset += button.size.height
            yOffset += menuSpacing
        }
        yOffset -= menuSpacing
        
        size = CGSize(width: maxWidth, height: yOffset)
        scrollView!.contentSizeChanged()
    }
}
