import ComposableArchitecture
import PurchaseClient
import RateAppClient

public enum ProductStatus: String {
    case loading
    case loaded
    case failure
}

public enum PurchaseMode {
    case showing
    case purchaseInProgress
    case restoreInProgress
}

public struct Purchase: ReducerProtocol {
    public struct State: Equatable {
        public var purchaseMade = false
        public var purchasePrice = "-"
        public var productStatus = ProductStatus.loading
        public var purchaseFailureMessage: String?
        public var purchaseInProgress: Bool {
            purchaseMode == .purchaseInProgress
        }
        public var restoreInProgress: Bool {
            purchaseMode == .restoreInProgress
        }
        public var purchaseMode = PurchaseMode.showing
        
        public init() {
            
        }
    }
    
    public enum Action {
        case onAppear
        case onDisappear
        
        case loadStatusMonitor
        case loadProduct
        
        case loadedProduct(Result<AppProduct, Error>)
        case statusChanged(Result<PurchaseStatus, Error>)
        
        case purchase
        case purchaseMade(Result<Bool, Error>)
        
        case restore
        case restoreMade(Result<Bool, Error>)
        
        case rateApp
    }
    
    public init() {
        
    }
    
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.purchaseClient) var purchaseClient
    @Dependency(\.rateAppClient) var rateAppClient
    
    public var body: some ReducerProtocolOf<Self> {
        Reduce {
            state, action in
            
            switch action {
            case .onAppear:
                return Effect.concatenate(
                    Effect(value: .loadProduct),
                    Effect(value: .loadStatusMonitor)
                )
                
            case .loadProduct:
                return Effect(purchaseClient.availableProduct())
                    .catchToEffect(Action.loadedProduct)
                    .receive(on: mainQueue)
                    .eraseToEffect()
                
            case .loadStatusMonitor:
                return Effect(purchaseClient.purchaseStatus())
                    .catchToEffect(Action.statusChanged)
                    .receive(on: mainQueue)
                    .eraseToEffect()
                    .cancellable(id: CancelID.status)

            case .onDisappear:
                return Effect.cancel(id: CancelID.status)
                
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
                guard state.productStatus == .loaded, state.purchaseMode == .showing else {
                    return .none
                }

                state.purchaseFailureMessage = nil
                state.purchaseMode = .purchaseInProgress
                
                return Effect(purchaseClient.purchase())
                    .catchToEffect(Action.purchaseMade)
                    .receive(on: mainQueue)
                    .eraseToEffect()
                
            case .purchaseMade(let result):
                state.purchaseMode = .showing
                switch result {
                case .success(_):
                    // success should come through state change
                    break
                case .failure(let error):
                    state.purchaseFailureMessage = error.localizedDescription
                }
                return .none
                
            case .restore:
                guard state.purchaseMode == .showing else {
                    return .none
                }
                
                state.purchaseMode = .restoreInProgress
                return Effect(purchaseClient.restore())
                    .catchToEffect(Action.restoreMade)
                    .receive(on: mainQueue)
                    .eraseToEffect()
                
            case .restoreMade(let result):
                state.purchaseMode = .showing
                switch result {
                case .success(_):
                    break
                case .failure(let error):
                    state.purchaseFailureMessage = error.localizedDescription
                }
                return .none
                
            case .rateApp:
                rateAppClient.rateAppManual()
                return .none
            }
        }
    }
    
    private enum CancelID {
        case status
    }
}
