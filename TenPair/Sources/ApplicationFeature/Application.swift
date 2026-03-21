import AppAdsFeature
import ComposableArchitecture
import Logging
import PlayFeature
import PurchaseClient

@Reducer
public struct Application {
  @ObservableState
  public struct State: Equatable {
    public var appAdsState = AppAds.State()
    public var playState = PlayReducer.State()
        
    public init() {
            
    }
  }
    
  public enum Action: Sendable {
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
                
        return Effect.run {
          send in
                    
          for await status in purchaseClient.purchaseStatusStream() {
            await send(.purchaseStateChanged(status))
          }
        }
                
      case .purchaseStateChanged(let status):
        switch status {
        case .notMade:
          Log.app.debug("Purchase not made. Load ads")
          return Effect.send(.appAds(.load))
        case .made:
          Log.app.debug("Purchase made. Unload ads")
          return Effect.send(.appAds(.unload))
        case .notLoaded:
          return .none
        }
                
      case .onDidBecomeActive:
        return .run { _ in await cloudMessages.checkForMessages() }
                
      case .play(.tappedHint), .play(.tappedReload):
        return Effect.send(.appAds(.incrementInterstitial))
                
      case .appAds:
        return .none
                
      case .play:
        return .none
      }
    }
    Scope(state: \.appAdsState, action: \.appAds, child: AppAds.init)
    Scope(state: \.playState, action: \.play, child: PlayReducer.init)
  }
}
