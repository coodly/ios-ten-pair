import ComposableArchitecture
import CloudMessagesClient

public struct SendFeedback: ReducerProtocol {
    public struct State: Equatable {
        internal var isLoggedIn = false

        internal var messages = IdentifiedArrayOf<Message>()
        internal var lastMessageId = ""

        @BindingState internal var message = ""
        internal var sumbitEnabled = false
        internal var sendingMessage = false
        
        public init() {
            
        }
    }
    
    public enum Action: BindableAction {
        case onAppear
        case onDisappear
        
        case checkLoggedIn
        case loadMessages
        
        case markLoggedIn(Bool)
        case markMessages([Message])
        
        case postMessage
        case markSent
        
        case binding(BindingAction<State>)
    }
    
    public init() {
        
    }
    
    @Dependency(\.cloudMessagesClient) var cloudMessagesClient
    @Dependency(\.mainQueue) var mainQueue
    
    public var body: some ReducerProtocolOf<Self> {
        BindingReducer()
        Reduce {
            state, action in
            
            switch action {
            case .onAppear:
                return EffectTask(value: .checkLoggedIn)
                
            case .checkLoggedIn:
                return EffectTask(cloudMessagesClient.checkLoggedIn())
                    .map({ .markLoggedIn($0) })
                    .receive(on: mainQueue)
                    .eraseToEffect()
                    .cancellable(id: CancelID.sendFeedback)
                
            case .loadMessages:
                return EffectTask(cloudMessagesClient.allMessages())
                    .map({ .markMessages($0.sorted()) })
                    .receive(on: mainQueue)
                    .eraseToEffect()
                    .cancellable(id: CancelID.sendFeedback)
                

            case .onDisappear:
                return EffectTask.cancel(id: CancelID.sendFeedback)
                
            case .markLoggedIn(let loggedIn):
                state.isLoggedIn = loggedIn
                if loggedIn {
                    return EffectTask(value: .loadMessages)
                } else {
                    return .none
                }
                
            case .markMessages(let messages):
                state.messages = IdentifiedArrayOf(uniqueElements: messages)
                state.lastMessageId = messages.last?.recordName ?? ""
                return .none
                
            case .postMessage:
                var sent = state.message
                state.message = ""
                state.sumbitEnabled = false
                guard sent.hasValue else {
                    return .none
                }
                state.sendingMessage = true
                return EffectTask(cloudMessagesClient.send(message: sent))
                    .map({ .markSent })
                    .receive(on: mainQueue)
                    .eraseToEffect()
                
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
