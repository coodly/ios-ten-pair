import AppAdsFeature
import ComposableArchitecture
import Logging
import PlayFeature
import PurchaseClient

public struct Application: Reducer {
    public struct State: Equatable {
        public var appAdsState = AppAds.State()
        public var playState = PlayReducer.State()
        
        public init() {
            
        }
    }
    
    public enum Action {
        case onDidLoad
        case onDidBecomeActive
        
        case purchaseStateChanged(PurchaseStatus)
        
        case appAds(AppAds.Action)
        case play(PlayReducer.Action)
    }
    
    public init() {
        
    }
    
    @Dependency(\.cloudMessagesClient) var cloudMessages
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.rateAppClient) var rateAppClient
    @Dependency(\.purchaseClient) var purchaseClient
    
    public var body: some ReducerOf<Self> {
        Reduce {
            state, action in
            
            switch action {
            case .onDidLoad:
                rateAppClient.appLaunch()
                guard purchaseClient.havePurchase else {
                    return .none
                }
                return Effect.publisher({ purchaseClient.purchaseStatus() })
                    .map(Action.purchaseStateChanged)
                
            case .purchaseStateChanged(let status):
                switch status {
                case .notMade:
                    Log.app.debug("Purchase not made. Load ads")
                    return Effect.send(.appAds(.load))
                case .made:
                    Log.app.debug("Purchase not made. Unload ads")
                    return Effect.send(.appAds(.unload))
                case .notLoaded:
                    return .none
                }
                
            case .onDidBecomeActive:
                cloudMessages.checkForMessages()
                return .none
                
            case .play(.tappedHint), .play(.tappedReload):
                return Effect.send(.appAds(.incrementInterstitial))
                
            case .appAds:
                return .none
                
            case .play:
                return .none
            }
        }
        Scope(state: \.appAdsState, action: /Action.appAds) {
            AppAds()
        }
        Scope(state: \.playState, action: /Action.play) {
            PlayReducer()
        }
    }
}
