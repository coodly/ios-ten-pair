import ComposableArchitecture
import RestartFeature
import Themes

public let menuReducer = Reducer<MenuState, MenuAction, MenuEnvironment>.combine(
    restartReducer
        .optional()
        .pullback(state: \.restartState, action: /MenuAction.restart, environment: \.restartEnv),
    reducer
)

private let reducer = Reducer<MenuState, MenuAction, MenuEnvironment>() {
    state, action, env in
    
    switch action {
    case .resume:
        return .none
        
    case .restartTapped:
        state.restartState = RestartState()
        return .none
        
    case .theme:
        let next = AppTheme.shared.switchToNext()
        state.activeThemeName = next.name
        return .none
        
    case .restart(.back):
        state.restartState = nil
        return .none
    
    case .restart:
        return .none
    }
}
