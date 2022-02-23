import ComposableArchitecture

public let sendFeedbackReducer = Reducer<SendFeedbackState, SendFeedbackAction, SendFeedbackEnvironment>.combine(
    reducer
)

private let reducer = Reducer<SendFeedbackState, SendFeedbackAction, SendFeedbackEnvironment>() {
    state, action, env in
    
    struct SendFeedbackCancel: Hashable {}
    
    switch action {
    case .onAppear:
        return Effect(value: .checkLoggedIn)
        
    case .checkLoggedIn:
        return Effect(env.cloudMessagesClient.checkLoggedIn())
            .map({ .markLoggedIn($0) })
            .receive(on: env.mainQueue)
            .eraseToEffect()
            .cancellable(id: SendFeedbackCancel())
        
    case .loadMessages:
        return Effect(env.cloudMessagesClient.allMessages())
            .map({ .markMessages($0.sorted()) })
            .receive(on: env.mainQueue)
            .eraseToEffect()
            .cancellable(id: SendFeedbackCancel())
        

    case .onDisappear:
        return Effect.cancel(id: SendFeedbackCancel())
        
    case .markLoggedIn(let loggedIn):
        state.isLoggedIn = loggedIn
        if loggedIn {
            return Effect(value: .loadMessages)
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
        return Effect(env.cloudMessagesClient.send(message: sent))
            .map({ .markSent })
            .receive(on: env.mainQueue)
            .eraseToEffect()
        
    case .markSent:
        state.sendingMessage = false
        return .none
        
    case .binding:
        state.sumbitEnabled = state.message.hasValue
        return .none
    }
}
.binding()

extension String {
    fileprivate var hasValue: Bool {
        !trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
