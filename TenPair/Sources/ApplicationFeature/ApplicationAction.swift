import AppAdsFeature
import PlayFeature
import PurchaseClient
import PurchaseFeature

public enum ApplicationAction {
    case onDidLoad
    case onDidBecomeActive
    
    case purchaseStateChanged(Result<PurchaseStatus, Error>)
    
    case appAds(AppAdsAction)
    case play(PlayAction)
    case purchase(PurchaseAction)
}
