import ComposableArchitecture

public let purchaseReducer = Reducer<PurchaseState, PurchaseAction, PurchaseEnvironment>.combine(
    reducer
)

private let reducer = Reducer<PurchaseState, PurchaseAction, PurchaseEnvironment>() {
    state, action, env in
    
    struct StatusCancellable: Hashable {}
    
    switch action {
    case .onAppear:
        return Effect.concatenate(
            Effect(value: .loadProduct),
            Effect(value: .loadStatusMonitor)
        )
        
    case .loadProduct:
        return Effect(env.purchaseClient.availableProduct())
            .catchToEffect(PurchaseAction.loadedProduct)
            .receive(on: env.mainQueue)
            .eraseToEffect()
        
    case .loadStatusMonitor:
        return Effect(env.purchaseClient.purchaseStatus())
            .catchToEffect(PurchaseAction.statusChanged)
            .receive(on: env.mainQueue)
            .eraseToEffect()
            .cancellable(id: StatusCancellable())

    case .onDisappear:
        return Effect.cancel(id: StatusCancellable())
        
    case .loadedProduct(let result):
        switch result {
        case .success(let product):
            state.productStatus = .loaded
            state.purchasePrice = product.formattedPrice
        case .failure(let error):
            state.productStatus = .failure
        }
        return .none
        
    case .statusChanged(let result):
        switch result {
        case .success(let status):
            state.purchaseMade = status == .made
        case .failure(let error):
            break
        }
        return .none

    case .purchase:
        guard state.productStatus == .loaded else {
            return .none
        }

        state.purchaseFailureMessage = nil
        state.purchaseInProgress = true
        
        return Effect(env.purchaseClient.purchase())
            .catchToEffect(PurchaseAction.purchaseMade)
            .receive(on: env.mainQueue)
            .eraseToEffect()
        
    case .purchaseMade(let result):
        state.purchaseInProgress = false
        switch result {
        case .success(_):
            // success should come through state change
            break
        case .failure(let error):
            state.purchaseFailureMessage = error.localizedDescription
        }
        return .none
        
    case .rateApp:
        return .none
    }
}
.debug()
