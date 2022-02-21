import RestartFeature
import Themes

public struct MenuState: Equatable {
    public var restartState: RestartState?
    
    public var activeThemeName: String
    
    public init() {
        activeThemeName = AppTheme.shared.active.name
    }
}
