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

class GameViewController: UIViewController {
    @IBOutlet var gameView: SKView!
    @IBOutlet var adContainerView: UIView!
    @IBOutlet var adContainerHeightConstraint: NSLayoutConstraint!
    private var bannerView: GADBannerView!
    private var products: [SKProduct]?
    
    var scene : TenPairGame?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        adContainerHeightConstraint.constant = 0
        
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.adUnitID = AdMobAdUnit
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.autoresizingMask = [.FlexibleTopMargin, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleBottomMargin]
        adContainerView.addSubview(bannerView)
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
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
        gameScene.controller = self
        scene = gameScene
        skView.allowsTransparency = false
        skView.shouldCullNonVisibleNodes = false
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.presentScene(scene)

        gameScene.startGame()
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
        }
    }
}

extension GameViewController: GADBannerViewDelegate {
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        loadAds()
        refreshProducts()
    }
    
    func loadAds() {
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID, "466da0f45d3a5e55de0e1b150016b580", "ff31957cce821a3df57613ad34e6293e"]
        bannerView.loadRequest(request)
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
