import AppAdsFeature
import PlayFeature
import PurchaseFeature

public enum ApplicationAction {
    case appAds(AppAdsAction)
    case play(PlayAction)
    case purchase(PurchaseAction)
}
