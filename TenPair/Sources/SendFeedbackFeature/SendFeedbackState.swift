import CloudMessagesClient
import ComposableArchitecture

public struct SendFeedbackState: Equatable {
    internal var isLoggedIn = false

    internal var messages = IdentifiedArrayOf<Message>()
    internal var lastMessageId = ""

    @BindableState internal var message = ""
    internal var sumbitEnabled = false
    internal var sendingMessage = false
    
    public init() {
        
    }
}
