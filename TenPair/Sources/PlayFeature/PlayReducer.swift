import ComposableArchitecture

public let playReducer = Reducer<PlayState, PlayAction, PlayEnvironment>.combine(
    reducer
)

private let reducer = Reducer<PlayState, PlayAction, PlayEnvironment>() {
    state, action, env in
    
    return .none
}
