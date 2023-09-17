import AppAdsFeature
import PlayFeature
import PurchaseFeature

public struct ApplicationState: Equatable {
    public var appAdsState = AppAds.State()
    public var playState = PlayReducer.State()
    
    public init() {
        
    }
}
