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
import iAd

let TenPairSaveDataKey = "NumbersGameSaveDataKey"

class GameViewController: UIViewController, ADBannerViewDelegate {
    @IBOutlet var gameView: SKView!
    @IBOutlet var adContainerView: UIView!
    @IBOutlet var adContainerHeightConstraint: NSLayoutConstraint!
    
    var banner: ADBannerView?
    var scene : TenPairGame?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        adContainerHeightConstraint.constant = 0
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
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
    
    override func viewDidAppear(animated: Bool) {
        loadAd()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            return UIInterfaceOrientationMask.All
        } else {
            return UIInterfaceOrientationMask.Portrait
        }
    }
    
    func loadAd() {
        if let banner = self.banner {
            return
        }
        
        let adBanner = ADBannerView(adType: ADAdType.Banner)
        self.banner = adBanner
        adBanner.delegate = self
        adBanner.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleBottomMargin]
        adContainerView.addSubview(adBanner)
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        banner.center = CGPointMake(CGRectGetWidth(adContainerView.frame) / 2, CGRectGetHeight(adContainerView.frame) / 2)
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.adContainerHeightConstraint.constant = CGRectGetHeight(banner.frame)
            self.view.layoutIfNeeded()
        })
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.adContainerHeightConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    func saveField() {
        let numbers = scene!.playScreen.playFieldNumbers()
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(numbers, forKey: TenPairSaveDataKey)
        defaults.synchronize()
    }
}
