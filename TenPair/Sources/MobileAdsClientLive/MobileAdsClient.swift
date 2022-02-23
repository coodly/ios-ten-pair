import Combine
import Config
import GoogleMobileAds
import Logging
import MobileAdsClient
import UIKit

extension MobileAdsClient {
    public static var live: MobileAdsClient {
        let proxy = AdsProxy()
        
        return MobileAdsClient(
            onLoad: proxy.load,
            onUnload: proxy.unload,
            onBannerView: proxy.bannerView(in:),
            onPresentInterstitial: proxy.presentInterstitial(on:),
            onReloadBannerInView: proxy.reloadBanner(in:),
            onShowBannerPublisher: {
                proxy.showBanner.eraseToAnyPublisher()
            }
        )
    }
}

private class AdsProxy: NSObject, GADBannerViewDelegate, GADFullScreenContentDelegate {
    fileprivate let showBanner = CurrentValueSubject<Bool, Never>(false)
    private var banner: GADBannerView?
    private var loaded = false
    private var interstitial: GADInterstitialAd?
    
    fileprivate func load() {
        Log.ads.debug("Load")
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        loaded = true
        
        guard let banner = banner else {
            return
        }
        reloadBanner(in: banner)
        loadInterstitial()
    }
    
    fileprivate func unload() {
        Log.ads.debug("Unload")
        showBanner.send(false)
        showBanner.send(completion: .finished)
        banner?.delegate = nil
        banner?.removeFromSuperview()
        banner = nil
        interstitial?.fullScreenContentDelegate = nil
        interstitial = nil
        loaded = false
    }
    
    fileprivate func presentInterstitial(on root: UIViewController) -> Bool {
        guard loaded else {
            return false
        }
        
        guard let interstitial = interstitial else {
            loadInterstitial()
            return false
        }

        interstitial.present(fromRootViewController: root)
        return true
    }
    
    fileprivate func bannerView(in root: UIViewController) -> UIView {
        let banner = GADBannerView(adSize: GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(root.view.frame.width))
        banner.adUnitID = AppConfig.current.adUnits.banner
        banner.rootViewController = root
        banner.delegate = self
        banner.isAutoloadEnabled = false
        self.banner = banner

        return banner
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        guard loaded else {
            return
        }
        
        Log.ads.debug("bannerViewDidReceiveAd")
        showBanner.send(true)
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        Log.ads.error("didFailToReceiveAdWithError: \(error)")
        showBanner.send(false)
    }
    
    fileprivate func reloadBanner(in view: UIView) {
        guard loaded else {
            return
        }
        
        let frame = view.frame.inset(by: view.safeAreaInsets)
        let width = frame.size.width
        Log.ads.debug("Load banner at width: \(width)")
        banner?.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(width)
        banner?.load(adRequest())
    }
    
    private func adRequest() -> GADRequest {
        let request = GADRequest()
        
        let extras = GADExtras()
        extras.additionalParameters = ["npa": "1"]
        request.register(extras)

        return request
    }
    
    private func loadInterstitial() {
        guard loaded else {
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
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        Log.ads.debug("Interstitial dismissed")
        interstitial = nil
        
        loadInterstitial()
    }
}
