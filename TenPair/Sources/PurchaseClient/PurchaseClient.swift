import Dependencies
import StoreKit
import XCTestDynamicOverlay

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

public struct PurchaseClient: Sendable {
    private let onAvailableProduct: @Sendable () async throws -> AppProduct
    private let onLoad: @Sendable () -> Void
    private let onPurchase: @Sendable () async throws -> Bool
    private let onPurchaseStatusStream: @Sendable () -> AsyncStream<PurchaseStatus>
    private let onRestore: @Sendable () async throws -> Bool
    
    public let havePurchase: Bool
    public init(
        havePurchase: Bool,
        onAvailableProduct: @Sendable @escaping () async throws -> AppProduct,
        onLoad: @Sendable @escaping () -> Void,
        onPurchase: @Sendable @escaping () async throws -> Bool,
        onPurchaseStatusStream: @Sendable @escaping () -> AsyncStream<PurchaseStatus>,
        onRestore: @Sendable @escaping () async throws -> Bool
    ) {
        self.havePurchase = havePurchase
        self.onAvailableProduct = onAvailableProduct
        self.onLoad = onLoad
        self.onPurchase = onPurchase
        self.onPurchaseStatusStream = onPurchaseStatusStream
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
    
    public func restore() async throws -> Bool {
        try await onRestore()
    }
    
    public func purchaseStatusStream() -> AsyncStream<PurchaseStatus> {
        onPurchaseStatusStream()
    }
}

extension PurchaseClient {
    public static let noPurchase = PurchaseClient(
        havePurchase: false,
        onAvailableProduct: { fatalError() },
        onLoad: {},
        onPurchase: { fatalError() },
        onPurchaseStatusStream: { fatalError() },
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
            onPurchaseStatusStream: unimplemented("\(Self.self).onPurchaseStatusStream"),
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
        onPurchaseStatusStream: {
            AsyncStream(unfolding: { PurchaseStatus.notMade })
        },
        onRestore: { fatalError() }
    )
    
    public static let purchaseMade = PurchaseClient(
        havePurchase: true,
        onAvailableProduct: { .noProduct },
        onLoad: {},
        onPurchase: { fatalError() },
        onPurchaseStatusStream: { AsyncStream(unfolding: { PurchaseStatus.made }) },
        onRestore: { fatalError() }
    )
}
#endif
