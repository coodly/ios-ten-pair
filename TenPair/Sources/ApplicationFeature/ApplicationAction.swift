import AppAdsFeature
import PlayFeature
import PurchaseClient

public enum ApplicationAction {
    case onDidLoad
    case onDidBecomeActive
    
    case purchaseStateChanged(Result<PurchaseStatus, Error>)
    
    case appAds(AppAds.Action)
    case play(PlayAction)
}
