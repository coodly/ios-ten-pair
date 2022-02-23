import ComposableArchitecture

public let appAdsReducer = Reducer<AppAdsState, AppAdsAction, AppAdsEnvironment>.combine(
    reducer
)

private let reducer = Reducer<AppAdsState, AppAdsAction, AppAdsEnvironment>() {
    state, action, env in

    switch action {
    case .onDidLoad:
        return Effect.concatenate(
            Effect(value: .loadShowBannerMonitor)
        )
        
    case .loadShowBannerMonitor:
        return Effect(env.adsClient.showBannerPublisher())
            .map({ AppAdsAction.markShowBanner($0) })
            .eraseToEffect()

    case .load:
        return .none
        
    case .markShowBanner(let show):
        state.showBannerAd = show
        return .none
    }
}
