import PurchaseFeature
import RestartFeature

public enum MenuAction {
    case resume
    case restartTapped
    case theme
    
    case purchase(PurchaseAction)
    case restart(RestartAction)
}
