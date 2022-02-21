import ComposableArchitecture

public let playSummaryReducer = Reducer<PlaySummaryState, PlaySummaryAction, PlaySummaryEnvironment>.combine(
    reducer
)

private let reducer = Reducer<PlaySummaryState, PlaySummaryAction, PlaySummaryEnvironment>() {
    state, action, env in
    
    switch action {
    case .update(let lines, let tiles):
        state.numbeOfLines = lines
        state.numberOfTiles = tiles
        return .none
    }
}
