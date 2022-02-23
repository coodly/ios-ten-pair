import AppAdsFeature
import PlayFeature
import PurchaseClient

public enum ApplicationAction {
    case onDidLoad
    case onDidBecomeActive
    
    case purchaseStateChanged(Result<PurchaseStatus, Error>)
    
    case appAds(AppAdsAction)
    case play(PlayAction)
}
