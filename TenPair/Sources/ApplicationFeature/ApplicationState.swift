import AppAdsFeature
import PurchaseFeature

public struct ApplicationState: Equatable {
    internal var appAdsState: AppAdsState?
    internal var purchaseState = PurchaseState()
    
    public init() {
        
    }
}
