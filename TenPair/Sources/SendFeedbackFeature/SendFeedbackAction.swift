import CloudMessagesClient
import ComposableArchitecture

public enum SendFeedbackAction: BindableAction {
    case onAppear
    case onDisappear
    
    case checkLoggedIn
    case loadMessages
    
    case markLoggedIn(Bool)
    case markMessages([Message])
    
    case postMessage
    case markSent
    
    case binding(BindingAction<SendFeedbackState>)
}
