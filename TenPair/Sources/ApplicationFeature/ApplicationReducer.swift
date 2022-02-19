import AppAdsFeature
import ComposableArchitecture
import PurchaseFeature

public let applicationReducer = Reducer<ApplicationState, ApplicationAction, ApplicationEnvironment>.combine(
    appAdsReducer
        .pullback(state: \.appAdsState, action: /ApplicationAction.appAds, environment: \.appAdsEnv),
    purchaseReducer
        .pullback(state: \.purchaseState, action: /ApplicationAction.purchase, environment: \.purchaseEnv),
    reducer
)

private let reducer = Reducer<ApplicationState, ApplicationAction, ApplicationEnvironment>() {
    state, action, env in
    
    switch action {
    case .appAds:
        return .none
        
    case .purchase:
        return .none
    }
}
