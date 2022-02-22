import ComposableArchitecture
import PurchaseFeature
import RestartFeature
import Themes

public let menuReducer = Reducer<MenuState, MenuAction, MenuEnvironment>.combine(
    purchaseReducer
        .optional()
        .pullback(state: \.purchaseState, action: /MenuAction.purchase, environment: \.purchaseEnv),
    restartReducer
        .optional()
        .pullback(state: \.restartState, action: /MenuAction.restart, environment: \.restartEnv),
    reducer
)

private let reducer = Reducer<MenuState, MenuAction, MenuEnvironment>() {
    state, action, env in
    
    switch action {
    case .willAppear:
        return Effect(value: .purchase(.onAppear))
        
    case .willDisappear:
        return Effect(value: .purchase(.onDisappear))
        
    case .resume:
        return .none
        
    case .restartTapped:
        state.restartState = RestartState()
        return .none
        
    case .theme:
        let next = AppTheme.shared.switchToNext()
        state.activeThemeName = next.localizedName
        return .none
        
    case .restart(.back):
        state.restartState = nil
        return .none
        
    case .purchase:
        return .none
    
    case .restart:
        return .none
    }
}
