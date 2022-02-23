import ComposableArchitecture

private let InterstitialShowThreshold = 10

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

    case .markShowBanner(let show):
        state.showBannerAd = show
        return .none

    case .load:
        env.adsClient.load()
        return .none

    case .unload:
        env.adsClient.unload()
        return .none
        
    case .incrementInterstitial:
        state.interstitialMarker += 1
        state.presentInterstitial = state.interstitialMarker >= InterstitialShowThreshold
        return Effect(value: .clearPresentInterstitial)
            .deferred(for: .milliseconds(100), scheduler: env.mainQueue)
            .eraseToEffect()
        
    case .interstitialShown:
        state.interstitialMarker = 0
        return .none
        
    case .clearPresentInterstitial:
        state.presentInterstitial = false
        return .none
    }
}
