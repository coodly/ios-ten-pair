import ComposableArchitecture

public let appAdsreducer = Reducer<AppAdsState, AppAdsAction, AppAdsEnvironment>.combine(
    reducer
)

private let reducer = Reducer<AppAdsState, AppAdsAction, AppAdsEnvironment>() {
    state, action, env in
    
    return .none
}
