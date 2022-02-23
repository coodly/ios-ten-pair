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
            onBannerView: proxy.bannerView(in:),
            onReloadBannerInView: proxy.reloadBanner(in:),
            onShowBannerPublisher: {
                proxy.showBanner.eraseToAnyPublisher()
            }
        )
    }
}

private class AdsProxy: NSObject, GADBannerViewDelegate {
    fileprivate let showBanner = CurrentValueSubject<Bool, Never>(false)
    private var banner: GADBannerView?
    
    fileprivate func bannerView(in root: UIViewController) -> UIView {
        let banner = GADBannerView(adSize: GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(root.view.frame.width))
        banner.adUnitID = AppConfig.current.adUnits.banner
        banner.rootViewController = root
        banner.delegate = self
        self.banner = banner

        return banner
    }
    
//    fileprivate func bannerPublisher(root: UIViewController) -> AnyPublisher<UIView?, Never> {
//        GADMobileAds.sharedInstance().start(completionHandler: nil)
//
//
//    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        Log.ads.debug("bannerViewDidReceiveAd")
        showBanner.send(true)
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        Log.ads.error("didFailToReceiveAdWithError: \(error)")
        showBanner.send(false)
    }
    
    fileprivate func reloadBanner(in view: UIView) {
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
}
