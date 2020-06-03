/*
 * Copyright 2017 Coodly LLC
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
    static let tickInterstitial = #selector(AdLoadingViewController.tickInterstitial)
}

class AdLoadingViewController: UIViewController {
    @IBOutlet private var adContainerView: UIView!
    @IBOutlet private var adContainerHeight: NSLayoutConstraint!
    private lazy var banner: GADBannerView = {
        let banner = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        banner.adUnitID = AppConfig.current.adUnits.banner
        banner.rootViewController = self
        banner.delegate = self
        return banner
    }()
    private lazy var interstitial = GADInterstitial(adUnitID: AppConfig.current.adUnits.interstitial)
    private var interstitialCount = 0
    
    @IBOutlet private var contentBottomWithAd: NSLayoutConstraint!
    @IBOutlet private var contentBottomWithoutAd: NSLayoutConstraint!
    
    private(set) lazy var gdpr = AdMobGDPRCheck()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gdpr.check()

        NotificationCenter.default.addObserver(self, selector: .tickInterstitial, name: .hintTaken, object: nil)
        NotificationCenter.default.addObserver(self, selector: .tickInterstitial, name: .fieldReload, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadAds), name: .personalizedAdsStatusChanged, object: nil)
        
        adContainerView.clipsToBounds = true
        adContainerView.addSubview(banner)
        banner.pinToSuperviewEdges()

        interstitial.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard AppConfig.current.ads else {
            return
        }
        
        loadAds()
    }
    
    @objc fileprivate func loadAds() {
        banner.load(adRequest())
        interstitial.load(adRequest())
    }
    
    @objc fileprivate func tickInterstitial() {
        interstitialCount += 1
        
        guard interstitialCount >= InterstitialShowTreshold, interstitial.isReady else {
            return
        }
        
        interstitialCount = 0
        interstitial.present(fromRootViewController: self)
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
}

extension AdLoadingViewController: GADInterstitialDelegate {
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial.load(adRequest())
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        Log.debug("Interstitial received")
    }
}

extension AdLoadingViewController: GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        Log.debug("Did receive ad")

        adContainerHeight.constant = bannerView.frame.height
        if contentBottomWithoutAd.isActive {
            adContainerView.alpha = 0
        }

        NSLayoutConstraint.deactivate([contentBottomWithoutAd])
        NSLayoutConstraint.activate([contentBottomWithAd])
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.3, delay: 1, animations: {
            self.adContainerView.alpha = 1
        })
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        Log.debug("didFailToReceiveAdWithError: \(error)")
        
        NSLayoutConstraint.deactivate([contentBottomWithAd])
        NSLayoutConstraint.activate([contentBottomWithAd])
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
