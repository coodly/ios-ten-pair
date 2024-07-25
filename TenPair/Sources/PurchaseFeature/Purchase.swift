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

public struct Purchase: Reducer {
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
    
  public enum Action: Sendable {
    case onAppear
    case onDisappear
        
    case loadStatusMonitor
    case loadProduct
        
    case loadedProduct(TaskResult<AppProduct>)
    case statusChanged(PurchaseStatus)
        
    case purchase
    case purchaseMade(TaskResult<Bool>)
        
    case restore
    case restoreMade(TaskResult<Bool>)
        
    case rateApp
  }
    
  public init() {
        
  }
    
  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.purchaseClient) var purchaseClient
  @Dependency(\.rateAppClient) var rateAppClient
    
  public var body: some ReducerOf<Self> {
    Reduce {
      state, action in
            
      switch action {
      case .onAppear:
        return Effect.concatenate(
          Effect.send(.loadProduct),
          Effect.send(.loadStatusMonitor)
        )
                
      case .loadProduct:
        return Effect.run {
          send in
                    
          await send(
            .loadedProduct(
              TaskResult {
                try await purchaseClient.availableProduct()
              }
            )
          )
        }
                
      case .loadStatusMonitor:
        return Effect.run {
          send in
                    
          for await status in purchaseClient.purchaseStatusStream() {
            await send(.statusChanged(status))
          }
        }
        .cancellable(id: CancelID.status)

      case .onDisappear:
        return Effect.cancel(id: CancelID.status)
                
      case .loadedProduct(let result):
        switch result {
        case .success(let product):
          state.productStatus = .loaded
          state.purchasePrice = product.formattedPrice
        case .failure:
          state.productStatus = .failure
        }
        return .none
                
      case .statusChanged(let status):
        state.purchaseMade = status == .made
        return .none

      case .purchase:
        guard state.productStatus == .loaded, state.purchaseMode == .showing else {
          return .none
        }

        state.purchaseFailureMessage = nil
        state.purchaseMode = .purchaseInProgress
                
        return Effect.run {
          send in
                    
          await send(
            .purchaseMade(
              TaskResult {
                try await purchaseClient.purchase()
              }
            )
          )
        }
                
      case .purchaseMade(let result):
        state.purchaseMode = .showing
        switch result {
        case .success:
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
        return Effect.run {
          send in
                    
          await send(
            .restoreMade(
              TaskResult {
                try await purchaseClient.restore()
              }
            )
          )
        }
                
      case .restoreMade(let result):
        state.purchaseMode = .showing
        switch result {
        case .success:
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
