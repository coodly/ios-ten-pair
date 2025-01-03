import ComposableArchitecture
import MobileAdsClient

private let InterstitialShowThreshold = 10

@Reducer
public struct AppAds: Sendable {
  public struct State: Equatable {
    public var showBannerAd = false
    public var presentInterstitial = false
        
    internal var interstitialMarker = 0
        
    public init() {
            
    }
  }
    
  public enum Action: Sendable {
    case onDidLoad
    case loadShowBannerMonitor
    case markShowBanner(Bool)

    case load
    case unload
        
    case incrementInterstitial
    case interstitialShown
    case clearPresentInterstitial
  }
    
  public init() {
        
  }
    
  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.mobileAdsClient) var mobileAds
    
  public var body: some ReducerOf<Self> {
    Reduce {
      state, action in
            
      switch action {
      case .onDidLoad:
        return Effect.concatenate(
          Effect.send(.loadShowBannerMonitor)
        )
                
      case .loadShowBannerMonitor:
        return Effect.publisher({ mobileAds.showBannerPublisher() })
          .map({ Action.markShowBanner($0) })

      case .markShowBanner(let show):
        state.showBannerAd = show
        return .none

      case .load:
        mobileAds.load()
        return .none

      case .unload:
        mobileAds.unload()
        return .none
                
      case .incrementInterstitial:
        state.interstitialMarker += 1
        state.presentInterstitial = state.interstitialMarker >= InterstitialShowThreshold
        return Effect.run {
          send in
                    
          try await mainQueue.sleep(for: .milliseconds(100))
          await send(.clearPresentInterstitial)
        }
                
      case .interstitialShown:
        state.interstitialMarker = 0
        return .none
                
      case .clearPresentInterstitial:
        state.presentInterstitial = false
        return .none
      }
    }
  }
}
