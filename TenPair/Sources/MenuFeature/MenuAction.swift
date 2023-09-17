import PurchaseFeature
import RestartFeature
import SendFeedbackFeature

public enum MenuAction {
    case willAppear
    case willDisappear
    
    case loadMessagesMonitor
    case unloadMessagesMonitor
    case markHasUnread(Bool)
    
    case resume
    case restartTapped
    case theme
    case feedback
    
    case purchase(PurchaseReducer.Action)
    case restart(Restart.Action)
    case sendFeedback(SendFeedbackAction)
}
