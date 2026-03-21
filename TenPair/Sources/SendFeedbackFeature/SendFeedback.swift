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
    var lastMessageId: String?
        
    public init() {
            
    }
  }
    
  public enum Action: BindableAction, Sendable {
    case onAppear
        
    case checkLoggedIn
    case markLoggedIn(Bool)
    case postMessage
    case markSent(String?)
        
    case binding(BindingAction<State>)
  }
    
  public init() {
        
  }
    
  @Dependency(\.cloudMessagesClient) var cloudMessagesClient
  @Dependency(\.continuousClock) var clock
    
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce {
      state, action in
            
      switch action {
      case .onAppear:
        @Shared(.hasUnreadMessages) var hasUnreadMessages
        $hasUnreadMessages.withLock { $0 = false }
        
        @Shared(.messages) var messages
        let lastMessage = messages.last?.recordName
        return .run { send in
          await send(.checkLoggedIn)
          try? await clock.sleep(for: .milliseconds(300))
          await send(.markSent(lastMessage), animation: .default)
        }
                
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
        return .run { send in
          let recordId = await cloudMessagesClient.send(message: sent)
          await send(.markSent(recordId))
        }
                
      case .markSent(let messageId):
        state.sendingMessage = false
        state.lastMessageId = messageId
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
