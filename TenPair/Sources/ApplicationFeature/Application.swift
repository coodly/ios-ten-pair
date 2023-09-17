import AppAdsFeature
import ComposableArchitecture
import Logging
import PlayFeature
import PurchaseClient

public struct Application: ReducerProtocol {
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
    
    public var body: some ReducerProtocolOf<Self> {
        Reduce {
            state, action in
            
            switch action {
            case .onDidLoad:
                rateAppClient.appLaunch()
                guard purchaseClient.havePurchase else {
                    return .none
                }
                return EffectTask.publisher({ purchaseClient.purchaseStatus() })
                    .map(Action.purchaseStateChanged)
                    .receive(on: mainQueue)
                    .eraseToEffect()
                
            case .purchaseStateChanged(let status):
                switch status {
                case .notMade:
                    Log.app.debug("Purchase not made. Load ads")
                    return EffectTask(value: .appAds(.load))
                case .made:
                    Log.app.debug("Purchase not made. Unload ads")
                    return EffectTask(value: .appAds(.unload))
                case .notLoaded:
                    return .none
                }
                
            case .onDidBecomeActive:
                cloudMessages.checkForMessages()
                return .none
                
            case .play(.tappedHint), .play(.tappedReload):
                return EffectTask(value: .appAds(.incrementInterstitial))
                
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
