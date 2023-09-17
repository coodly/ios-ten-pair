import Combine
import Dependencies
import StoreKit
import XCTestDynamicOverlay

public enum PurchaseStatus: Equatable {
    case notLoaded
    case notMade
    case made
}

public enum PurchaseError: LocalizedError {
    case noProducts
}

public struct AppProduct: Equatable {
    public let identifier: String
    public let formattedPrice: String
    public let product: SKProduct?
    
    public init(identifier: String, formattedPrice: String, product: SKProduct?) {
        self.identifier = identifier
        self.formattedPrice = formattedPrice
        self.product = product
    }
}

extension AppProduct {
    public static var noProduct = AppProduct(identifier: "-", formattedPrice: "-", product: nil)
}

public struct PurchaseClient {
    private let onAvailableProduct: () async throws -> AppProduct
    private let onLoad: (() -> Void)
    private let onPurchase: (() -> AnyPublisher<Bool, Error>)
    private let onPurchaseStatus: (() -> AnyPublisher<PurchaseStatus, Error>)
    private let onRestore: (() -> AnyPublisher<Bool, Error>)
    
    public let havePurchase: Bool
    public init(
        havePurchase: Bool,
        onAvailableProduct: @escaping () async throws -> AppProduct,
        onLoad: @escaping (() -> Void),
        onPurchase: @escaping (() -> AnyPublisher<Bool, Error>),
        onPurchaseStatus: @escaping (() -> AnyPublisher<PurchaseStatus, Error>),
        onRestore: @escaping (() -> AnyPublisher<Bool, Error>)
    ) {
        self.havePurchase = havePurchase
        self.onAvailableProduct = onAvailableProduct
        self.onLoad = onLoad
        self.onPurchase = onPurchase
        self.onPurchaseStatus = onPurchaseStatus
        self.onRestore = onRestore
    }
    
    public func load() {
        onLoad()
    }
    
    public func availableProduct() async throws -> AppProduct {
        try await onAvailableProduct()
    }
    
    public func purchase() -> AnyPublisher<Bool, Error> {
        onPurchase()
    }
    
    public func purchaseStatus() -> AnyPublisher<PurchaseStatus, Error> {
        onPurchaseStatus()
    }
    
    public func restore() -> AnyPublisher<Bool, Error> {
        onRestore()
    }
}

extension PurchaseClient {
    public static let noPurchase = PurchaseClient(
        havePurchase: false,
        onAvailableProduct: { fatalError() },
        onLoad: {},
        onPurchase: { fatalError() },
        onPurchaseStatus: { fatalError() },
        onRestore: { fatalError() }
    )
}

extension PurchaseClient: TestDependencyKey {
    public static var testValue: PurchaseClient {
        PurchaseClient(
            havePurchase: unimplemented("\(Self.self).havePurchase"),
            onAvailableProduct: unimplemented("\(Self.self).onAvailableProduct"),
            onLoad: unimplemented("\(Self.self).onLoad"),
            onPurchase: unimplemented("\(Self.self).onPurchase"),
            onPurchaseStatus: unimplemented("\(Self.self).onPurchaseStatus"),
            onRestore: unimplemented("\(Self.self).onRestore")
        )
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
        havePurchase: true,
        onAvailableProduct: { fatalError() },
        onLoad: { },
        onPurchase: { fatalError() },
        onPurchaseStatus: {
            let currentValue = CurrentValueSubject<PurchaseStatus, Error>(.notMade)
            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                currentValue.send(.made)
            }
            return currentValue.eraseToAnyPublisher()
        },
        onRestore: { fatalError() }
    )
    
    public static let purchaseMade = PurchaseClient(
        havePurchase: true,
        onAvailableProduct: { .noProduct },
        onLoad: {},
        onPurchase: { fatalError() },
        onPurchaseStatus: { Just(PurchaseStatus.made).setFailureType(to: Error.self).eraseToAnyPublisher() },
        onRestore: { fatalError() }
    )
}
#endif
