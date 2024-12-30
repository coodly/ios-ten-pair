import CloudMessagesClient
import ComposableArchitecture
import MenuFeature
import PlaySummaryFeature
import PurchaseClient
import RateAppClient

public enum RestartAction: Equatable {
  case regular
  case random(Int)
}

@Reducer
public struct PlayReducer {
  public struct State: Equatable {
    public var menuState: Menu.State?
    public var playSummaryState = PlaySummary.State()
        
    public var restartAction: RestartAction?
        
    public init() {
            
    }
  }
    
  public enum Action: Sendable {
    case tappedMenu
        
    case menu(Menu.Action)
    case playSummary(PlaySummary.Action)
        
    case tappedReload
    case tappedHint
        
    case sendRateEvent
  }
    
  public init() {
        
  }
    
  @Dependency(\.cloudMessagesClient) var cloudMessages
  @Dependency(\.purchaseClient) var purchaseClient
  @Dependency(\.rateAppClient) var rateAppClient
    
  public var body: some ReducerOf<Self> {
    Reduce {
      state, action in
            
      switch action {
      case .tappedMenu:
        state.restartAction = nil
        state.menuState = Menu.State(
          feedbackEnabled: cloudMessages.feedbackEnabled,
          havePurchase: purchaseClient.havePurchase
        )
        return .none
            
      case .tappedReload:
        return .none
                
      case .tappedHint:
        return .none
                
      case .sendRateEvent:
        rateAppClient.maybeRateEvent()
        return .none
                
      case .menu(.resume):
        state.menuState = nil
        return .none
            
      case .menu(.restart(.regular)):
        state.restartAction = .regular
        state.menuState = nil
        return Effect.send(.sendRateEvent)
                
      case .menu(.restart(.random(let lines))):
        state.restartAction = .random(lines)
        state.menuState = nil
        return Effect.send(.sendRateEvent)

      case .menu:
        return .none
                
      case .playSummary:
        return .none
      }
    }
    .ifLet(\.menuState, action: /Action.menu) {
      Menu()
    }
    Scope(state: \.playSummaryState, action: /Action.playSummary) {
      PlaySummary()
    }
  }
}
