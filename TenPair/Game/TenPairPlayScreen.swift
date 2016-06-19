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
import SWLogger
import StoreKit
import LaughingAdventure

private let ActionButtonsTrayHeight: CGFloat = 50

let TenPairGameStart = [1, 2, 3, 4, 5, 6, 7, 8, 9,
                        1, 1, 1, 2, 1, 3, 1, 4, 1,
                        5, 1, 6, 1, 7, 1, 8, 1, 9]

class TenPairPlayScreen: GameScreen {
    var topMenuBar: TenPairMenuBar?
    var scrollView: GameScrollView?
    var numbersField: TenPairNumbersField?
    var startField = TenPairGameStart
    private var actionButtons: HintButtonTray?
    var fullVersionProduct: SKProduct?
    var purchaser: Purchaser!
    weak var interstitial: InterstitialPresenter!
    
    override func loadContent() {
        name = "TenPairPlayScreen"
        color = TenPairTheme.currentTheme.backgroundColor!
        
        let scrollView = GameScrollView()
        self.scrollView = scrollView
        scrollView.size = size
        scrollView.contentInset = UIEdgeInsetsMake(60, 0, 10 + ActionButtonsTrayHeight + 10, 0)
        addGameView(scrollView)
        
        let field = TenPairNumbersField()
        numbersField = field
        field.presentedNumbers = startField
        field.anchorPoint = CGPointZero
        field.presentationWidth = size.width
        scrollView.present(field)
        
        let topMenuBar = TenPairMenuBar()
        self.topMenuBar = topMenuBar
        topMenuBar.size = CGSizeMake(size.width, 50)
        addGameView(topMenuBar)

        field.fieldStatus = topMenuBar.fieldStatus
        field.updateFieldStatus()
        
        field.gameWonAction = SKAction.runBlock() {
            let winScreen = TenPairWinScreen()
            winScreen.restartGameAction = SKAction.runBlock() {
                self.restartGame(winScreen)
            }
            self.game!.presentModalScreen(winScreen)
        }

        topMenuBar.menuButton!.action = SKAction.runBlock() {
            let menuScreen = TenPairMenuScreen()
            menuScreen.fullVersionProduct = self.fullVersionProduct
            menuScreen.purchaser = self.purchaser
            menuScreen.restartGameAction = SKAction.runBlock() {
                self.restartGame(menuScreen)
            }
            self.game!.presentModalScreen(menuScreen)
        }
        
        topMenuBar.reloadButton!.action = SKAction.runBlock() {
            self.reloadNumbers() {
                onMainThread() {
                    self.interstitial.presentInterstitial()
                }
            }
        }
        
        actionButtons = HintButtonTray()
        actionButtons!.anchorPoint = CGPointZero
        actionButtons!.size = CGSizeMake(ActionButtonsTrayHeight, ActionButtonsTrayHeight)
        addGameView(actionButtons!)
        
        actionButtons!.hintButton.action = SKAction.runBlock() {
            var loading: TenPairLoadingScreen?
            
            let reload = SKAction.runBlock() {
                self.numbersField?.searchForMatch() {
                    result in
                    
                    Log.debug("Search complete: \(result)")
                    switch result {
                    case .FoundOnScreen:
                        //no op
                        break
                    case .NotFound:
                        let popup = AlertViewScreen()
                        popup.message = NSLocalizedString("game.hints.no.more.moves.message", comment: "")
                        popup.addAction("reload") {
                            self.game?.dismissScreen(popup)
                            self.reloadNumbers()
                        }
                        self.game?.presentModalScreen(popup)
                    case .FoundOffScreen(let offset):
                        let scrollTo = offset - self.scrollView!.size.height / 2
                        self.scrollView!.setContentOffset(CGPointMake(0, scrollTo), animated: true)
                    }
                    
                    self.game!.dismissScreen(loading!)
                    
                    self.interstitial.presentInterstitial()
                }
            }
            
            loading = self.executeGameAction(reload)
        }
    }
    
    override func positionContent() {
        topMenuBar!.position = CGPointMake(0, size.height - topMenuBar!.size.height)
        topMenuBar!.size.width = size.width
        
        numbersField!.presentationWidth = size.width
        
        scrollView!.size = size
        
        actionButtons!.position = CGPointMake(0, 10)
        
        super.positionContent()
    }
    
    override func handleTapAt(point: CGPoint) {
        let locationInField = scrollView!.translatePointToContent(point)
        numbersField!.tappedAt(locationInField)
    }
    
    func reloadNumbers(completion: (() -> ())? = nil) {
        var loading: TenPairLoadingScreen?
        
        let reload = SKAction.runBlock() {
            self.numbersField!.reloadNumbers(SKAction.runBlock({ () -> Void in
                self.topMenuBar!.reloadButton!.userInteractionEnabled = true
                self.game!.dismissScreen(loading!)
                
                completion?()
            }))
        }
        
        loading = executeGameAction(reload)
    }
    
    func restartGame(menuScreen: TenPairMenuScreen) {
        var loading: TenPairLoadingScreen?

        let restart = SKAction.runBlock() {
            self.numbersField!.presentedNumbers = TenPairGameStart
            self.numbersField!.restartGame()
            self.game!.dismissScreen(loading!)
        }
        
        loading = executeGameAction(restart)
    }
    
    func executeGameAction(action: SKAction) -> TenPairLoadingScreen {
        let loading = TenPairLoadingScreen()
        let show = SKAction.runBlock() {
            self.game!.presentLoadingView(loading)
        }
        let delay = SKAction.waitForDuration(1)
        let sequence = SKAction.sequence([show, delay, action])
        runAction(sequence)
        
        return loading
    }
    
    func playFieldNumbers() -> [Int] {
        return numbersField!.presentedNumbers
    }
}
