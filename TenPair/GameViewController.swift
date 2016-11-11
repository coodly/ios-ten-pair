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

import UIKit
import SpriteKit
import SWLogger
import GoogleMobileAds
import LaughingAdventure
import StoreKit
import MessageUI

private extension Selector {
    static let checkFullVersion = #selector(GameViewController.checkFullVersion)
}

class GameViewController: UIViewController, FullVersionHandler, InterstitialPresenter, FeedbackEmailSender {
    @IBOutlet var gameView: SKView!
    @IBOutlet var adContainerView: UIView!
    @IBOutlet var adContainerHeightConstraint: NSLayoutConstraint!
    fileprivate var bannerView: GADBannerView?
    fileprivate var products: [SKProduct]?
    fileprivate var purchaser: Purchaser!
    var interstitial: GADInterstitial?
    
    var scene : TenPairGame?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: .checkFullVersion, name: NSNotification.Name(rawValue: CheckAppFullVersionNotification), object: nil)
        
        adContainerHeightConstraint.constant = 0
        
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView!.adUnitID = AdMobAdUnit
        bannerView!.rootViewController = self
        bannerView!.delegate = self
        bannerView!.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
        adContainerView.addSubview(bannerView!)
        
        purchaser = Purchaser()
        purchaser.passiveMonitor = self
        purchaser.startMonitoring()
    }

    override var shouldAutorotate : Bool {
        return true
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadAds()
        refreshProducts()
        
        scene?.playScreen.purchaser = purchaser
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if scene != nil {
            return
        }

        let skView = gameView!

        let gameScene = TenPairGame(size: skView.bounds.size)
        if let save = UserDefaults.standard.object(forKey: TenPairSaveDataKey) as? [Int] {
            gameScene.startField = save
        }
        gameScene.scaleMode = SKSceneScaleMode.resizeFill
        scene = gameScene
        skView.allowsTransparency = false
        skView.shouldCullNonVisibleNodes = false
        if AppConfig.current.stats {
            skView.showsFPS = true
            skView.showsNodeCount = true
        }
        skView.presentScene(scene)

        gameScene.playScreen.runningOn = UIDevice.current.userInterfaceIdiom == .phone ? Platform.phone : Platform.pad
        gameScene.playScreen.interstitial = self
        
        gameScene.startGame()
        
        gameScene.playScreen.sendFeedbackHandler = {
            [unowned self] in
            
            
            let feedback = Feedback.mainController()
            let navigation = UINavigationController(rootViewController: feedback)
            navigation.modalPresentationStyle = .formSheet
            self.present(navigation, animated: true, completion: nil)
        }
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return UIInterfaceOrientationMask.all
        } else {
            return UIInterfaceOrientationMask.portrait
        }
    }
    
    func saveField() {
        let numbers = scene!.playScreen.playFieldNumbers()
        let defaults = UserDefaults.standard
        defaults.set(numbers, forKey: TenPairSaveDataKey)
        defaults.synchronize()
    }
    
    @objc fileprivate func checkFullVersion() {
        guard fullVersionUnlocked() else {
            return
        }
        
        guard let banner = bannerView else {
            return
        }
        
        bannerView = nil
        
        let animation = {
            self.adContainerHeightConstraint.constant = 0
        }
        
        let completion: (Bool) -> () = {
            completed in
            
            banner.removeFromSuperview()
        }
        
        UIView.animate(withDuration: 0.3, animations: animation, completion: completion)
    }
}

extension GameViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            presentEmailSendErrorAlert()
            return
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
}

extension GameViewController: PurchaseMonitor {
    func purchaseResult(_ result: PurchaseResult, for identifier: String) {
        Log.debug("Purchase: \(result) - \(identifier)")
        
        guard identifier == FullVersionIdentifier else {
            return
        }
        
        guard result == .restored || result == .success else {
            return
        }
        
        markFullVersionUnlocked()
    }
}

extension GameViewController: ProductsHandler {
    func refreshProducts() {
        if let _ = products {
            return
        }
        
        retrieveProducts([FullVersionIdentifier]) {
            products, invalid in
            
            Log.debug("products: \(products)")
            Log.debug("Invalid: \(invalid)")
            
            self.products = products
            
            let fullVersion = products.filter({ $0.productIdentifier == FullVersionIdentifier }).first
            self.scene?.playScreen.fullVersionProduct = fullVersion
        }
    }
}

extension GameViewController: GADBannerViewDelegate {
    func loadAds() {
        if fullVersionUnlocked() {
            Log.debug("Have full version. No ads")
            return
        }
        
        loadInterstitial()
        
        guard let banner = bannerView else {
            return
        }
        
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID, "466da0f45d3a5e55de0e1b150016b580", "ff31957cce821a3df57613ad34e6293e"]
        banner.load(request)
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView!) {
        Log.debug("adViewDidReceiveAd: \(bannerView.frame)")
        bannerView.center = CGPoint(x: view.frame.width / 2, y: bannerView.frame.height / 2)
        UIView.animate(withDuration: 0.3, animations: {
            self.adContainerHeightConstraint.constant = bannerView.frame.height
        }) 
    }
    
    func adView(_ bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        Log.error("didFailToReceiveAdWithError: \(error)")
        if adContainerHeightConstraint.constant == 0 {
            return
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.adContainerHeightConstraint.constant = 0
        }) 
    }
    
}
