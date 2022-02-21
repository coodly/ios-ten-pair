import ComposableArchitecture

public let purchaseReducer = Reducer<PurchaseState, PurchaseAction, PurchaseEnvironment>.combine(
    reducer
)

private let reducer = Reducer<PurchaseState, PurchaseAction, PurchaseEnvironment>() {
    state, action, env in
    
    switch action {
    case .rateApp:
        return .none
    }
}
