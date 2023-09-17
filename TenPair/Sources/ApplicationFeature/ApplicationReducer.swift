import AppAdsFeature
import ComposableArchitecture
import Logging
import PlayFeature

public let applicationReducer = Reducer<ApplicationState, ApplicationAction, ApplicationEnvironment>.combine(
    AnyReducer {
        env in
        
        AppAds()
    }
    .pullback(state: \.appAdsState, action: /ApplicationAction.appAds, environment: { $0 }),
    playReducer
        .pullback(state: \.playState, action: /ApplicationAction.play, environment: \.playEnv),
    reducer
)

private let reducer = Reducer<ApplicationState, ApplicationAction, ApplicationEnvironment>() {
    state, action, env in
    
    switch action {
    case .onDidLoad:
        env.rateAppClient.appLaunch()
        guard env.purchaseClient.havePurchase else {
            return .none
        }
        return Effect(env.purchaseClient.purchaseStatus())
            .catchToEffect(ApplicationAction.purchaseStateChanged)
            .receive(on: env.mainQueue)
            .eraseToEffect()
        
    case .purchaseStateChanged(let result):
        switch result {
        case .success(let status) where status == .notMade:
            Log.app.debug("Purchase not made. Load ads")
            return Effect(value: .appAds(.load))
        case .success(let status) where status == .made:
            Log.app.debug("Purchase not made. Unload ads")
            return Effect(value: .appAds(.unload))
        case .success:
            return .none
        case .failure:
            return .none
        }
        
    case .onDidBecomeActive:
        env.cloudMessages.checkForMessages()
        return .none
        
    case .play(.tappedHint), .play(.tappedReload):
        return Effect(value: .appAds(.incrementInterstitial))
        
    case .appAds:
        return .none
        
    case .play:
        return .none
    }
}
