import ComposableArchitecture
import CloudMessagesClient

@Reducer
public struct SendFeedback {
  @ObservableState
  public struct State: Equatable {
    internal var isLoggedIn = false

    internal var message = ""
    internal var sumbitEnabled = false
    internal var sendingMessage = false
        
    public init() {
            
    }
  }
    
  public enum Action: BindableAction, Sendable {
    case onAppear
        
    case checkLoggedIn
    case markLoggedIn(Bool)
    case postMessage
    case markSent
        
    case binding(BindingAction<State>)
  }
    
  public init() {
        
  }
    
  @Dependency(\.cloudMessagesClient) var cloudMessagesClient
  @Dependency(\.mainQueue) var mainQueue
    
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce {
      state, action in
            
      switch action {
      case .onAppear:
        @Shared(.hasUnreadMessages) var hasUnreadMessages
        $hasUnreadMessages.withLock { $0 = false }
        return Effect.send(.checkLoggedIn)
                
      case .checkLoggedIn:
        return Effect.run {
          send in
                    
          await send(
            .markLoggedIn(cloudMessagesClient.checkLoggedIn())
          )
        }
        .cancellable(id: CancelID.sendFeedback)
                                
      case .markLoggedIn(let loggedIn):
        state.isLoggedIn = loggedIn
        return .none
                
      case .postMessage:
        let sent = state.message
        state.message = ""
        state.sumbitEnabled = false
        guard sent.hasValue else {
          return .none
        }
        state.sendingMessage = true
        return Effect.publisher({ cloudMessagesClient.send(message: sent) })
          .map({ .markSent })
                
      case .markSent:
        state.sendingMessage = false
        return .none
                
      case .binding:
        state.sumbitEnabled = state.message.hasValue
        return .none
      }
    }
  }
    
  private enum CancelID {
    case sendFeedback
  }
}


extension String {
  fileprivate var hasValue: Bool {
    !trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }
}
