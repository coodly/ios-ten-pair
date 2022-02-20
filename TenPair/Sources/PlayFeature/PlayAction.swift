import MenuFeature
import PlaySummaryFeature

public enum PlayAction {
    case menu(MenuAction)
    case playSummary(PlaySummaryAction)
}
