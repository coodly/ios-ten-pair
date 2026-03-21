import Dependencies
import DependenciesMacros
import StoreKit

public enum PurchaseStatus: String, Equatable, Sendable {
  case notLoaded
  case notMade
  case made
}

public enum PurchaseError: LocalizedError {
  case noProducts
}

public struct AppProduct: Equatable, Sendable {
  public let identifier: String
  public let formattedPrice: String

  public init(identifier: String, formattedPrice: String) {
    self.identifier = identifier
    self.formattedPrice = formattedPrice
  }
}

extension AppProduct {
  public static let noProduct = AppProduct(identifier: "-", formattedPrice: "-")
}

@DependencyClient
public struct PurchaseClient: Sendable {
  public internal(set) var havePurchase: @Sendable () -> Bool = { false }
  public internal(set) var onAvailableProduct: @Sendable () async throws -> AppProduct
  public internal(set) var onLoad: @Sendable () -> Void
  public internal(set) var onPurchase: @Sendable () async throws -> Bool
  public internal(set) var onPurchaseStatusStream: @Sendable () -> AsyncStream<PurchaseStatus> = { .finished }
  public internal(set) var onRestore: @Sendable () async throws -> Bool

  public func load() {
    onLoad()
  }

  public func availableProduct() async throws -> AppProduct {
    try await onAvailableProduct()
  }

  public func purchase() async throws -> Bool {
    try await onPurchase()
  }

  public func restore() async throws -> Bool {
    try await onRestore()
  }

  public func purchaseStatusStream() -> AsyncStream<PurchaseStatus> {
    onPurchaseStatusStream()
  }
}

extension PurchaseClient {
  public static let noPurchase = PurchaseClient(
    havePurchase: { false },
    onAvailableProduct: { fatalError() },
    onLoad: {},
    onPurchase: { fatalError() },
    onPurchaseStatusStream: { fatalError() },
    onRestore: { fatalError() }
  )
}

extension PurchaseClient: TestDependencyKey {
  public static var testValue: PurchaseClient {
    Self()
  }
}

extension DependencyValues {
  public var purchaseClient: PurchaseClient {
    get { self[PurchaseClient.self] }
    set { self[PurchaseClient.self] = newValue }
  }
}

#if DEBUG
  extension PurchaseClient {
    public static let delayedUnlock = PurchaseClient(
      havePurchase: { true },
      onAvailableProduct: { fatalError() },
      onLoad: { },
      onPurchase: { fatalError() },
      onPurchaseStatusStream: {
        AsyncStream(unfolding: { PurchaseStatus.notMade })
      },
      onRestore: { fatalError() }
    )

    public static let purchaseMade = PurchaseClient(
      havePurchase: { true },
      onAvailableProduct: { .noProduct },
      onLoad: {},
      onPurchase: { fatalError() },
      onPurchaseStatusStream: { AsyncStream(unfolding: { PurchaseStatus.made }) },
      onRestore: { fatalError() }
    )
  }
#endif
