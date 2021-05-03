/*
 * Copyright 2020 Coodly LLC
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

import Config
import Combine
import GoogleMobileAds
import Logging
import UIKit

private let InterstitialShowThreshold = 10

private extension Selector {
    static let tickInterstitial = #selector(AdsViewController.tickInterstitial)
}

internal class AdsViewController: UIViewController {
    @IBOutlet private var bottomWithAds: NSLayoutConstraint!
    @IBOutlet private var bottomWithoutAds: NSLayoutConstraint!
    @IBOutlet private var bannerContainer: UIView!
    @IBOutlet private var bannerHeight: NSLayoutConstraint!
    
    private lazy var banner: GADBannerView? = {
        let banner = GADBannerView(adSize: GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(view.frame.width))
        banner.adUnitID = AppConfig.current.adUnits.banner
        banner.rootViewController = self
        banner.delegate = self
        return banner
    }()
    
    private var interstitial: GADInterstitialAd?
    private var interstitialCount = 0
    
    private var adsStatusSubscription: AnyCancellable?
    private var adsDisabled = false
    private var shouldLoadAds: Bool {
        !adsDisabled
    }
    private var sdkLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(setNeedsStatusBarAppearanceUpdate), name: .themeChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: .tickInterstitial, name: .hintTaken, object: nil)
        NotificationCenter.default.addObserver(self, selector: .tickInterstitial, name: .fieldReload, object: nil)

        bannerContainer.clipsToBounds = true
        bannerContainer.addSubview(banner!)
        banner!.pinToSuperviewEdges()
        
        adsStatusSubscription = RevenueCatPurchase.shared.adsStatus
            .receive(on: DispatchQueue.main)
            .sink() {
                [weak self]
                
                status in
                
                self?.changed(status: status)
            }
    }
    
    private func changed(status: ShowAdsStatus) {
        switch status {
        case .unknown:
            break
        case .show:
            loadAds()
        case .removed:
            adsDisabled = true
            hideBanner() {
                self.banner = nil
                self.interstitial = nil
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        AppTheme.shared.active.statusBar
    }
    
    public override var shouldAutorotate: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .allButUpsideDown
        } else {
            return .portrait
        }
    }
    
    override func viewWillTransition(to size: CGSize,
                            with coordinator: UIViewControllerTransitionCoordinator) {
      super.viewWillTransition(to:size, with:coordinator)
      coordinator.animate(alongsideTransition: { _ in
        self.loadBannerAd()
      })
    }
        
    @objc fileprivate func loadAds() {
        if adsDisabled {
            return
        }
        
        initializeSDK()
        
        loadBannerAd()
        loadInterstitial()
    }
    
    private func initializeSDK() {
        if sdkLoaded {
            return
        }
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        sdkLoaded = true
    }
    
    private func loadBannerAd() {
        if adsDisabled {
            return
        }
        
        guard AppConfig.current.ads else {
            return
        }
        
        let frame = { () -> CGRect in
          if #available(iOS 11.0, *) {
            return view.frame.inset(by: view.safeAreaInsets)
          } else {
            return view.frame
          }
        }()
        let viewWidth = frame.size.width

        banner?.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        banner?.load(adRequest())
    }

    private func adRequest() -> GADRequest {
        let request = GADRequest()
        
        let extras = GADExtras()
        extras.additionalParameters = ["npa": "1"]
        request.register(extras)

        return request
    }
    
    @objc fileprivate func tickInterstitial() {
        if adsDisabled {
            return
        }
        
        interstitialCount += 1
        
        guard let interstitial = self.interstitial else {
            return
        }
        
        guard interstitialCount >= InterstitialShowThreshold else {
            return
        }
        
        interstitialCount = 0
        interstitial.present(fromRootViewController: self)
    }
    
    private func hideBanner(completion: (() -> Void)? = nil) {
        NSLayoutConstraint.deactivate([bottomWithAds])
        NSLayoutConstraint.activate([bottomWithoutAds])
        
        let animation = {
            self.view.layoutIfNeeded()
        }
        let animationCompletion: ((Bool) -> Void) = {
            _ in
            
            completion?()
        }
        
        UIView.animate(withDuration: 0.3, animations: animation, completion: animationCompletion)
    }
    
    private func loadInterstitial() {
        guard shouldLoadAds else {
            return
        }
        
        guard interstitial == nil else {
            return
        }
        
        GADInterstitialAd.load(withAdUnitID: AppConfig.current.adUnits.interstitial, request: adRequest()) {
            loaded, error in
            
            if let error = error {
                Log.ads.error("Load interstitial error: \(error)")
            } else if let ad = loaded {
                Log.ads.debug("Loaded interstitial")
                ad.fullScreenContentDelegate = self
                self.interstitial = ad
            } else {
                Log.ads.debug("No interstitial")
            }
        }
    }
}

extension AdsViewController: GADFullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        Log.ads.debug("Interstitial dismissed")
        interstitial = nil
        
        loadInterstitial()
    }
}

extension AdsViewController: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        Log.ads.debug("Did receive ad")

        bannerHeight.constant = bannerView.frame.height
        if bottomWithoutAds.isActive {
            bannerContainer.alpha = 0
        }

        NSLayoutConstraint.deactivate([bottomWithoutAds])
        NSLayoutConstraint.activate([bottomWithAds])
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.3, delay: 1, animations: {
            self.bannerContainer.alpha = 1
        })
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        Log.ads.debug("didFailToReceiveAdWithError: \(error)")

        hideBanner()
    }
}
