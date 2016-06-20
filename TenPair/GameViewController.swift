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
    private var bannerView: GADBannerView?
    private var products: [SKProduct]?
    private var purchaser: Purchaser!
    var interstitial: GADInterstitial?
    
    var scene : TenPairGame?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: .checkFullVersion, name: CheckAppFullVersionNotification, object: nil)
        
        adContainerHeightConstraint.constant = 0
        
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView!.adUnitID = AdMobAdUnit
        bannerView!.rootViewController = self
        bannerView!.delegate = self
        bannerView!.autoresizingMask = [.FlexibleTopMargin, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleBottomMargin]
        adContainerView.addSubview(bannerView!)
        
        purchaser = Purchaser()
        purchaser.passiveMonitor = self
        purchaser.startMonitoring()
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        loadAds()
        refreshProducts()
        
        scene?.playScreen.purchaser = purchaser
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if scene != nil {
            return
        }

        let skView = gameView

        let gameScene = TenPairGame(size: skView.bounds.size)
        if let save = NSUserDefaults.standardUserDefaults().objectForKey(TenPairSaveDataKey) as? [Int] {
            gameScene.startField = save
        }
        gameScene.scaleMode = SKSceneScaleMode.ResizeFill
        scene = gameScene
        skView.allowsTransparency = false
        skView.shouldCullNonVisibleNodes = false
        if !ReleaseBuild {
            skView.showsFPS = true
            skView.showsNodeCount = true
        }
        skView.presentScene(scene)

        gameScene.playScreen.runningOn = UIDevice.currentDevice().userInterfaceIdiom == .Phone ? Platform.Phone : Platform.Pad
        gameScene.playScreen.interstitial = self
        
        gameScene.startGame()
        
        gameScene.playScreen.sendFeedbackHandler = {
            [unowned self] in
            
            self.sendFeedback(FeedbackEmail, subject: FeedbackTitle, mailDelegate: self)
        }
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            return UIInterfaceOrientationMask.All
        } else {
            return UIInterfaceOrientationMask.Portrait
        }
    }
    
    func saveField() {
        let numbers = scene!.playScreen.playFieldNumbers()
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(numbers, forKey: TenPairSaveDataKey)
        defaults.synchronize()
    }
    
    @objc private func checkFullVersion() {
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
        
        UIView.animateWithDuration(0.3, animations: animation, completion: completion)
    }
}

extension GameViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        if let _ = error {
            presentEmailSendErrorAlert()
            return
        }
        
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension GameViewController: PurchaseMonitor {
    func purchase(result: PurchaseResult, forProduct identifier: String) {
        Log.debug("Purchase: \(result) - \(identifier)")
        
        guard identifier == FullVersionIdentifier else {
            return
        }
        
        guard result == .Restored || result == .Success else {
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
        banner.loadRequest(request)
    }
    
    func adViewDidReceiveAd(bannerView: GADBannerView!) {
        Log.debug("adViewDidReceiveAd: \(bannerView.frame)")
        bannerView.center = CGPointMake(view.frame.width / 2, bannerView.frame.height / 2)
        UIView.animateWithDuration(0.3) {
            self.adContainerHeightConstraint.constant = bannerView.frame.height
        }
    }
    
    func adView(bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        Log.error("didFailToReceiveAdWithError: \(error)")
        if adContainerHeightConstraint.constant == 0 {
            return
        }
        
        UIView.animateWithDuration(0.3) {
            self.adContainerHeightConstraint.constant = 0
        }
    }
    
}
