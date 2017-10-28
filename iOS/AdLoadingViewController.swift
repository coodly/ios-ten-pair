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
    private var interstitial: GADInterstitial?
    private var interstitialCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: .tickInterstitial, name: .hintTaken, object: nil)
        NotificationCenter.default.addObserver(self, selector: .tickInterstitial, name: .fieldReload, object: nil)
        
        adContainerHeight.constant = 0
        
        adContainerView.clipsToBounds = true
        adContainerView.addSubview(banner)
        banner.translatesAutoresizingMaskIntoConstraints = false
        
        let top = NSLayoutConstraint(item: banner, attribute: .top, relatedBy: .equal, toItem: adContainerView, attribute: .top, multiplier: 1, constant: 0)
        let left = NSLayoutConstraint(item: banner, attribute: .left, relatedBy: .equal, toItem: adContainerView, attribute: .left, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: banner, attribute: .right, relatedBy: .equal, toItem: adContainerView, attribute: .right, multiplier: 1, constant: 0)
        adContainerView.addConstraints([top, left, right])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        banner.load(request)
        
        loadInterstitial()
    }
    
    private func loadInterstitial() {
        interstitial = GADInterstitial(adUnitID: AppConfig.current.adUnits.interstitial)
        interstitial!.delegate = self
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        interstitial!.load(request)
    }
    
    @objc fileprivate func tickInterstitial() {
        interstitialCount += 1
        
        guard interstitialCount >= InterstitialShowTreshold, (interstitial?.isReady ?? false) else {
            return
        }
        
        interstitialCount = 0
        interstitial?.present(fromRootViewController: self)
    }
}

extension AdLoadingViewController: GADInterstitialDelegate {
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        loadInterstitial()
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        Log.debug("Interstitial received")
    }
}

extension AdLoadingViewController: GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        Log.debug("Did receive ad")
        if #available(iOS 11, *) {
            adContainerHeight.constant = bannerView.frame.height + view.safeAreaInsets.bottom
        } else {
            adContainerHeight.constant = bannerView.frame.height
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        Log.debug("didFailToReceiveAdWithError: \(error)")
        adContainerHeight.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
