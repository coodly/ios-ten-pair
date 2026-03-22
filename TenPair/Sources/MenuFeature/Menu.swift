import ComposableArchitecture
import PurchaseFeature
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
    
  public enum Action: Sendable, ViewAction {
    case delegate(Delegate)
    case local(Local)
    case willAppear
                
    case purchase(Purchase.Action)
    case restart(Restart.Action)
    case sendFeedback(SendFeedback.Action)
    case view(View)
    
    public enum Delegate: Sendable {
      case dismiss
      case startRegular
      case startRandom(Int)
      case switchedTheme
    }
    
    public enum Local: Sendable {
      case markActive(String)
    }
    
    public enum View: Sendable {
      case tappedResume
      case tappedRestart
      case tappedTheme
      case tappedFeedback
    }
  }
    
  public init() {
        
  }
    
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .willAppear:
        if state.purchaseState != nil {
          return .send(.purchase(.load))
        } else {
          return .none
        }
                                
      case .local(let action):
        switch action {
        case .markActive(let name):
          state.activeThemeName = name
          return .none
        }
        
      case .restart(.delegate(let action)):
        switch action {
        case .startRegular:
          return .send(.delegate(.startRegular))
          
        case .startRandom(let number):
          return .send(.delegate(.startRandom(number)))
          
        case .close:
          state.restartState = nil
          return .none
        }
        
      case .sendFeedback(.delegate(let action)):
        switch action {
        case .dismiss:
          state.sendFeedbackState = nil
          return .none
        }
        
      case .view(let action):
        switch action {
        case .tappedResume:
          let havePurchases = state.purchaseState != nil
          return .run { send in
            if havePurchases {
              await send(.purchase(.unload))
            }
            await send(.delegate(.dismiss))
          }
          
        case .tappedFeedback:
          state.sendFeedbackState = SendFeedback.State()
          return .none
          
        case .tappedRestart:
          state.restartState = Restart.State()
          return .none
          
        case .tappedTheme:
          return .run { @MainActor send in
            let next = AppTheme.shared.switchToNext()
            send(.local(.markActive(next.localizedName)))
            send(.delegate(.switchedTheme))
          }
        }
                                                
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
