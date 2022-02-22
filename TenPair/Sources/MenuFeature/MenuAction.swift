import PurchaseFeature
import RestartFeature

public enum MenuAction {
    case willAppear
    case willDisappear
    
    case resume
    case restartTapped
    case theme
    
    case purchase(PurchaseAction)
    case restart(RestartAction)
}
