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

import UIKit
import GoogleMobileAds

private let InterstitialShowTreshold = 10

private extension Selector {
    static let tickInterstitial = #selector(AdsViewController.tickInterstitial)
}

internal class AdsViewController: UIViewController {
    @IBOutlet private var bottomWithAds: NSLayoutConstraint!
    @IBOutlet private var bottomWithoutAds: NSLayoutConstraint!
    @IBOutlet private var bannerContainer: UIView!
    @IBOutlet private var bannerHeight: NSLayoutConstraint!
    
    private lazy var banner: GADBannerView = {
        let banner = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        banner.adUnitID = AppConfig.current.adUnits.banner
        banner.rootViewController = self
        banner.delegate = self
        return banner
    }()
    
    private(set) lazy var gdpr = AdMobGDPRCheck()
    
    private lazy var interstitial = createInterstitial()
    private var interstitialCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        gdpr.check()
        gdpr.showOn = self

        NotificationCenter.default.addObserver(self, selector: #selector(setNeedsStatusBarAppearanceUpdate), name: .themeChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: .tickInterstitial, name: .hintTaken, object: nil)
        NotificationCenter.default.addObserver(self, selector: .tickInterstitial, name: .fieldReload, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadAds), name: .personalizedAdsStatusChanged, object: nil)

        bannerContainer.clipsToBounds = true
        bannerContainer.addSubview(banner)
        banner.pinToSuperviewEdges()
        
        loadAds()
        
        children.compactMap({ $0 as? GDPRCheckConsumer }).forEach({ $0.gdprCheck = gdpr })
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
        loadBannerAd()
        
        if AppConfig.current.ads {
            interstitial.load(adRequest())
        }
    }
    
    private func loadBannerAd() {
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

        banner.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        banner.load(adRequest())
    }

    private func adRequest() -> GADRequest {
        let request = GADRequest()
        if gdpr.canShowPersonalizedAds {
            Log.ads.debug("Can show personalized")
        } else {
            Log.ads.debug("Load non personalized ads")
            let extras = GADExtras()
            extras.additionalParameters = ["npa": "1"]
            request.register(extras)
        }
        return request
    }
    
    @objc fileprivate func tickInterstitial() {
        interstitialCount += 1
        
        guard interstitialCount >= InterstitialShowTreshold, interstitial.isReady else {
            return
        }
        
        interstitialCount = 0
        interstitial.present(fromRootViewController: self)
    }
    
    private func createInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: AppConfig.current.adUnits.interstitial)
        interstitial.delegate = self
        return interstitial
    }
}

extension AdsViewController: GADInterstitialDelegate {
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createInterstitial()
        interstitial.load(adRequest())
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        Log.ads.debug("Interstitial received")
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        Log.ads.error("didFailToReceiveAdWithError: \(error)")
    }
}

extension AdsViewController: GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
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
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        Log.ads.debug("didFailToReceiveAdWithError: \(error)")
        
        NSLayoutConstraint.deactivate([bottomWithAds])
        NSLayoutConstraint.activate([bottomWithoutAds])
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
