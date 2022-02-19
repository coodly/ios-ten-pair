import AppAdsFeature
import PurchaseFeature

public struct ApplicationState: Equatable {
    public var appAdsState = AppAdsState()
    internal var purchaseState = PurchaseState()
    
    public init() {
        
    }
}
