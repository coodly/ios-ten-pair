public enum AppAdsAction {
    case onDidLoad
    case loadShowBannerMonitor
    case markShowBanner(Bool)

    case load
    case unload
    
    case incrementInterstitial
    case interstitialShown
    case clearPresentInterstitial
}
