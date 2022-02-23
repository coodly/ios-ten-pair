import AppAdsFeature
import PlayFeature
import PurchaseFeature

public struct ApplicationState: Equatable {
    public var appAdsState = AppAdsState()
    public var playState = PlayState()
    
    public init() {
        
    }
}
