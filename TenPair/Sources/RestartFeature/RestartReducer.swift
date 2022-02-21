import ComposableArchitecture

public let restartReducer = Reducer<RestartState, RestartAction, RestartEnvironment>.combine(
    reducer
)

private let reducer = Reducer<RestartState, RestartAction, RestartEnvironment>() {
    state, action, env in
    
    return .none
}
