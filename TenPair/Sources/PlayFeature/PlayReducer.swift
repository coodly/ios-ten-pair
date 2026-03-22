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
  @ObservableState
  public struct State: Equatable, Sendable {
    public var menuState: Menu.State?
    public var playSummaryState = PlaySummary.State()
    public var hintButtonTray = ButtonTray.State()
    public var undoButtonTray = ButtonTray.State()
        
    public var restartAction: RestartAction?
        
    public init() {
            
    }
  }
    
  public enum Action: Sendable {
    case hintTray(ButtonTray.Action)
    case undoTray(ButtonTray.Action)
    
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
    Reduce<State, Action> { state, action in
      switch action {
      case .menu(.delegate(let action)):
        switch action {
        case .startRegular:
          state.restartAction = .regular
          state.menuState = nil
          return Effect.send(.sendRateEvent)

        case .startRandom(let number):
          state.restartAction = .random(number)
          state.menuState = nil
          return Effect.send(.sendRateEvent)

        case .switchedTheme:
          state.playSummaryState.updateTheme()
          state.hintButtonTray.updateTheme()
          state.undoButtonTray.updateTheme()
          return .none
        }
        
      case .tappedMenu:
        state.restartAction = nil
        state.menuState = Menu.State(
          feedbackEnabled: cloudMessages.feedbackEnabled(),
          havePurchase: purchaseClient.havePurchase()
        )
        return .none
            
      case .hintTray:
        return .none
        
      case .undoTray:
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
            
      case .menu:
        return .none
                
      case .playSummary:
        return .none
      }
    }
    .ifLet(\.menuState, action: \.menu, then: Menu.init)
    Scope(state: \.hintButtonTray, action: \.hintTray, child: ButtonTray.init)
    Scope(state: \.playSummaryState, action: \.playSummary, child: PlaySummary.init)
    Scope(state: \.undoButtonTray, action: \.undoTray, child: ButtonTray.init)
  }
}
