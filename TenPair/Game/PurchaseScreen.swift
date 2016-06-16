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

class PurchaseScreen: GameScreen {
    private var scrollView: GameScrollView!
    var product: SKProduct!
    
    override func loadContent() {
        super.loadContent()
        
        color = UIColor.whiteColor()
        
        scrollView = GameScrollView()
        
        let width = min(400, size.width - 20)
        let text = SKSpriteNode.multiLineLabel(NSLocalizedString("purchase.screen.sales.letter", comment: ""), font: "Copperplate", fontSize: 20, maxWidth: width)
        text.color = TenPairTheme.currentTheme.defaultNumberTileColor!
        
        let purchaseTitle = String.localizedStringWithFormat(NSLocalizedString("purchase.screen.purchase.button", comment: ""), product.formattedPrice())
        let purchase = TenPairMenuButton.menuItemWithTitle(purchaseTitle) {
            
        }
        purchase.size = CGSizeMake(width, 40)
        
        let restoreButton = TenPairMenuButton.menuItemWithTitle(NSLocalizedString("purchase.screen.restore.button", comment: "")) {
            
        }
        restoreButton.size = CGSizeMake(width, 40)
        
        let backButton = TenPairMenuButton.menuItemWithTitle(NSLocalizedString("purchase.screen.back.button", comment: "")) {
            self.game?.dismissScreen(self)
        }
        backButton.size = CGSizeMake(width, 40)

        
        let content = Content()
        content.appendItem(text)
        content.appendItem(purchase)
        content.appendItem(restoreButton)
        content.appendItem(backButton)
        
        scrollView.present(content)
        
        addGameView(scrollView)
    }
    
    override func positionContent() {
        scrollView.size = size
        
        super.positionContent()
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
    
    private override func presentationInsets() -> UIEdgeInsets {
        return UIEdgeInsetsMake(20, 0, 0, 0)
    }
    
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
