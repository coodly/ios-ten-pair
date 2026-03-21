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
    case willAppear
    case willDisappear
        
    case resume
    case restartTapped
    case theme
    case feedback
        
    case purchase(Purchase.Action)
    case restart(Restart.Action)
    case sendFeedback(SendFeedback.Action)
  }
    
  public init() {
        
  }
    
  @Dependency(\.cloudMessagesClient) var cloudMessages
  @Dependency(\.mainQueue) var mainQueue
    
  public var body: some ReducerOf<Self> {
    Reduce {
      state, action in
            
      switch action {
      case .willAppear:
        return Effect.send(.purchase(.onAppear))
                
      case .willDisappear:
        return Effect.concatenate(
          Effect.send(.purchase(.onDisappear))
        )
                
      case .resume:
        return .none
                
      case .restartTapped:
        state.restartState = Restart.State()
        return .none
                
      case .theme:
        let next = AppTheme.shared.switchToNext()
        state.activeThemeName = next.localizedName
        return .none
                
      case .restart(.back):
        state.restartState = nil
        return .none
                                        
      case .feedback:
        state.sendFeedbackState = SendFeedback.State()
        return .none
                
      case .sendFeedback(.onDisappear):
        state.sendFeedbackState = nil
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
