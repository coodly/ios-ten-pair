import ComposableArchitecture
import PlaySummaryFeature

public let playReducer = Reducer<PlayState, PlayAction, PlayEnvironment>.combine(
    playSummaryReducer.pullback(state: \.playSummaryState, action: /PlayAction.playSummary, environment: \.playSummaryEnv),
    reducer
)

private let reducer = Reducer<PlayState, PlayAction, PlayEnvironment>() {
    state, action, env in
    
    switch action {
    case .playSummary:
        return .none
    }
}
