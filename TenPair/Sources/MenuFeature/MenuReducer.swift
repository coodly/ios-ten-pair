import ComposableArchitecture

public let menuReducer = Reducer<MenuState, MenuAction, MenuEnvironment>.combine(
    reducer
)

private let reducer = Reducer<MenuState, MenuAction, MenuEnvironment>() {
    state, action, env in
    
    return .none
}
