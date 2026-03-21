import ComposableArchitecture
import PurchaseFeature
import RestartFeature
import SendFeedbackFeature
import Sharing
import Themes

@Reducer
public struct Menu {
  @ObservableState
  public struct State: Equatable {
    public var purchaseState: Purchase.State?
    public var restartState: Restart.State?
    public var sendFeedbackState: SendFeedback.State?
        
    public var activeThemeName: String
    public let feedbackEnabled: Bool
        
    public init(feedbackEnabled: Bool, havePurchase: Bool) {
      activeThemeName = AppTheme.shared.active.localizedName
      purchaseState = havePurchase ? Purchase.State() : nil
      self.feedbackEnabled = feedbackEnabled
    }
  }
    
  public enum Action: Sendable {
    case delegate(Delegate)
    case local(Local)
    case willAppear
    case willDisappear
        
    case resume
    case restartTapped
    case theme
    case feedback
        
    case purchase(Purchase.Action)
    case restart(Restart.Action)
    case sendFeedback(SendFeedback.Action)
    
    public enum Delegate: Sendable {
      case switchedTheme
    }
    
    public enum Local: Sendable {
      case markActive(String)
    }
  }
    
  public init() {
        
  }
    
  @Dependency(\.cloudMessagesClient) var cloudMessages
  @Dependency(\.mainQueue) var mainQueue
    
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .willAppear:
        return Effect.send(.purchase(.onAppear))
                
      case .willDisappear:
        return Effect.concatenate(
          Effect.send(.purchase(.onDisappear))
        )
        
      case .local(let action):
        switch action {
        case .markActive(let name):
          state.activeThemeName = name
          return .none
        }
                
      case .resume:
        return .none
                
      case .restartTapped:
        state.restartState = Restart.State()
        return .none
                
      case .theme:
        return .run { @MainActor send in
          let next = AppTheme.shared.switchToNext()
          send(.local(.markActive(next.localizedName)))
          send(.delegate(.switchedTheme))
        }
                
      case .restart(.back):
        state.restartState = nil
        return .none
                                        
      case .feedback:
        state.sendFeedbackState = SendFeedback.State()
        return .none
                                
      case .delegate:
        return .none
        
      case .purchase:
        return .none
            
      case .restart:
        return .none

      case .sendFeedback:
        return .none
      }
    }
    .ifLet(\.purchaseState, action: \.purchase, then: Purchase.init)
    .ifLet(\.restartState, action: \.restart, then: Restart.init)
    .ifLet(\.sendFeedbackState, action: \.sendFeedback, then: SendFeedback.init)
  }
    
  private enum CancelID {
    case messages
  }
}
