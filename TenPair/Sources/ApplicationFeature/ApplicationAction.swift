import AppAdsFeature
import PurchaseFeature

public enum ApplicationAction {
    case appAds(AppAdsAction)
    case purchase(PurchaseAction)
}
