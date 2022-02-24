import MenuFeature
import PlaySummaryFeature

public enum PlayAction {
    case tappedMenu
    
    case menu(MenuAction)
    case playSummary(PlaySummaryAction)
    
    case tappedReload
    case tappedHint
    
    case sendRateEvent
}
