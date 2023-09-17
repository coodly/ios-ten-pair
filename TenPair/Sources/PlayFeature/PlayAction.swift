import MenuFeature
import PlaySummaryFeature

public enum PlayAction {
    case tappedMenu
    
    case menu(Menu.Action)
    case playSummary(PlaySummary.Action)
    
    case tappedReload
    case tappedHint
    
    case sendRateEvent
}
