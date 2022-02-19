import ComposableArchitecture

public let playSummaryReducer = Reducer<PlaySummaryState, PlaySummaryAction, PlaySummaryEnvironment>.combine(
    reducer
)

private let reducer = Reducer<PlaySummaryState, PlaySummaryAction, PlaySummaryEnvironment>() {
    state, action, env in
    
    return .none
}
