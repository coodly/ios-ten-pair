import ComposableArchitecture
import MenuFeature
import PlaySummaryFeature

public let playReducer = Reducer<PlayState, PlayAction, PlayEnvironment>.combine(
    menuReducer
        .optional()
        .pullback(state: \.menuState, action: /PlayAction.menu, environment: \.menuEnv),
    playSummaryReducer.pullback(state: \.playSummaryState, action: /PlayAction.playSummary, environment: \.playSummaryEnv),
    reducer
)

private let reducer = Reducer<PlayState, PlayAction, PlayEnvironment>() {
    state, action, env in
    
    switch action {
    case .menu:
        return .none
        
    case .playSummary:
        return .none
    }
}
