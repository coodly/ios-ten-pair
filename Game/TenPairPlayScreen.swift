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
    fileprivate var actionButtons: HintButtonTray?
    var fullVersionProduct: SKProduct?
    var purchaser: Purchaser!
    weak var interstitial: InterstitialPresenter!
    var sendFeedbackHandler: (() -> ())?
    var runningOn = Platform.phone
    
    override func loadContent() {
        name = "TenPairPlayScreen"
        color = TenPairTheme.currentTheme.backgroundColor!
        
        let scrollView = GameScrollView()
        self.scrollView = scrollView
        scrollView.size = size
        #if os(iOS)
            scrollView.contentInset = UIEdgeInsetsMake(60, 0, 10 + ActionButtonsTrayHeight + 10, 0)
        #else
            scrollView.contentInset = NSEdgeInsetsMake(60, 0, 10 + ActionButtonsTrayHeight + 10, 0)
        #endif
        addGameView(scrollView)
        
        let field = TenPairNumbersField()
        numbersField = field
        field.runningOn = runningOn
        field.presentedNumbers = startField
        field.anchorPoint = CGPoint.zero
        field.presentationWidth = size.width
        scrollView.present(field)
        
        let topMenuBar = TenPairMenuBar()
        self.topMenuBar = topMenuBar
        topMenuBar.size = CGSize(width: size.width, height: 50)
        addGameView(topMenuBar)

        field.fieldStatus = topMenuBar.fieldStatus
        field.updateFieldStatus()
        
        field.gameWonAction = SKAction.run() {
            let winScreen = TenPairWinScreen()
            winScreen.restartGameAction = SKAction.run() {
                [unowned winScreen] in
                
                self.restartGame(winScreen)
            }
            self.game!.presentModal(screen: winScreen)
        }

        topMenuBar.menuButton!.action = SKAction.run() {
            let menuScreen = TenPairMenuScreen()
            menuScreen.fullVersionProduct = self.fullVersionProduct
            menuScreen.purchaser = self.purchaser
            menuScreen.sendFeedbackHandler = self.sendFeedbackHandler
            menuScreen.restartGameAction = SKAction.run() {
                [unowned menuScreen] in
                
                self.restartGame(menuScreen)
            }
            self.game!.presentModal(screen: menuScreen)
        }
        
        topMenuBar.reloadButton!.action = SKAction.run() {
            self.reloadNumbers() {
                DispatchQueue.main.async {
                    self.interstitial.presentInterstitial()
                }
            }
        }
        
        actionButtons = HintButtonTray()
        actionButtons!.anchorPoint = CGPoint.zero
        actionButtons!.size = CGSize(width: ActionButtonsTrayHeight, height: ActionButtonsTrayHeight)
        addGameView(actionButtons!)
        
        actionButtons!.hintButton.action = SKAction.run() {
            var loading: TenPairLoadingScreen?
            
            let reload = SKAction.run() {
                self.numbersField?.searchForMatch() {
                    result in
                    
                    var showInterstitial = true
                    
                    Log.debug("Search complete: \(result)")
                    switch result {
                    case .foundOnScreen:
                        //no op
                        break
                    case .notFound:
                        showInterstitial = false
                        let popup = AlertViewScreen()
                        popup.message = NSLocalizedString("game.hints.no.more.moves.message", comment: "")
                        popup.addAction("reload") {
                            self.reloadNumbers()
                        }
                        self.game?.presentModal(screen: popup)
                    case .foundOffScreen(let offset):
                        let scrollTo = offset - self.scrollView!.size.height / 2
                        self.scrollView!.setContentOffset(CGPoint(x: 0, y: scrollTo), animated: true)
                    }
                    
                    self.game!.dismiss(loading!)
                    
                    if showInterstitial {
                        self.interstitial.presentInterstitial()
                    }
                }
            }
            
            loading = self.executeGameAction(reload)
        }
    }
    
    override func positionContent() {
        topMenuBar!.position = CGPoint(x: 0, y: size.height - topMenuBar!.size.height)
        topMenuBar!.size.width = size.width
        
        numbersField!.presentationWidth = size.width
        
        scrollView!.size = size
        
        actionButtons!.position = CGPoint(x: 0, y: 10)
        
        super.positionContent()
    }
    
    override func handleTap(at point: CGPoint) {
        let locationInField = scrollView!.translatePointToContent(point)
        numbersField!.tappedAt(locationInField)
    }
    
    func reloadNumbers(_ completion: (() -> ())? = nil) {
        var loading: TenPairLoadingScreen?
        
        let reload = SKAction.run() {
            self.numbersField!.reloadNumbers(SKAction.run({ () -> Void in
                self.topMenuBar!.reloadButton!.enable()
                self.game!.dismiss(loading!)
                
                completion?()
            }))
        }
        
        loading = executeGameAction(reload)
    }
    
    func restartGame(_ menuScreen: TenPairMenuScreen) {
        var loading: TenPairLoadingScreen?

        let restart = SKAction.run() {
            self.numbersField!.presentedNumbers = TenPairGameStart
            self.numbersField!.restartGame()
            self.game!.dismiss(loading!)
        }
        
        loading = executeGameAction(restart)
    }
    
    func executeGameAction(_ action: SKAction) -> TenPairLoadingScreen {
        let loading = TenPairLoadingScreen()
        let show = SKAction.run() {
            self.game!.present(loading: loading)
        }
        let delay = SKAction.wait(forDuration: 1)
        let sequence = SKAction.sequence([show, delay, action])
        run(sequence)
        
        return loading
    }
    
    func playFieldNumbers() -> [Int] {
        return numbersField!.presentedNumbers
    }
}
