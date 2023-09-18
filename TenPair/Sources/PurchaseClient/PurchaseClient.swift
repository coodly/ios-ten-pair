import Combine
import Dependencies
import StoreKit
import XCTestDynamicOverlay

public enum PurchaseStatus: Equatable, Sendable {
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

public struct PurchaseClient: Sendable {
    private let onAvailableProduct: @Sendable () async throws -> AppProduct
    private let onLoad: @Sendable () -> Void
    private let onPurchase: @Sendable () async throws -> Bool
    private let onPurchaseStatus: @Sendable () -> AnyPublisher<PurchaseStatus, Never>
    private let onRestore: @Sendable () async throws -> Bool
    
    public let havePurchase: Bool
    public init(
        havePurchase: Bool,
        onAvailableProduct: @Sendable @escaping () async throws -> AppProduct,
        onLoad: @Sendable @escaping () -> Void,
        onPurchase: @Sendable @escaping () async throws -> Bool,
        onPurchaseStatus: @Sendable @escaping () -> AnyPublisher<PurchaseStatus, Never>,
        onRestore: @Sendable @escaping () async throws -> Bool
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
    
    public func purchase() async throws -> Bool {
        try await onPurchase()
    }
    
    public func purchaseStatus() -> AnyPublisher<PurchaseStatus, Never> {
        onPurchaseStatus()
    }
    
    public func restore() async throws -> Bool {
        try await onRestore()
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
            let currentValue = CurrentValueSubject<PurchaseStatus, Never>(.notMade)
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
        onPurchaseStatus: { Just(PurchaseStatus.made).eraseToAnyPublisher() },
        onRestore: { fatalError() }
    )
}
#endif
