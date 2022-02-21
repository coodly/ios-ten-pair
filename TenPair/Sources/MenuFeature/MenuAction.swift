import RestartFeature

public enum MenuAction {
    case resume
    case restartTapped
    case theme
    
    case restart(RestartAction)
}
