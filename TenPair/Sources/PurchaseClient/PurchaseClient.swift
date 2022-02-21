import Combine
import StoreKit

public enum PurchaseStatus: Equatable {
    case notLoaded
    case notMade
    case made
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
    private let onAvailableProduct: (() -> AnyPublisher<AppProduct, Error>)
    private let onLoad: (() -> Void)
    private let onPurchase: (() -> AnyPublisher<Bool, Error>)
    private let onPurchaseStatus: (() -> AnyPublisher<PurchaseStatus, Error>)
    private let onRestore: (() -> AnyPublisher<Bool, Error>)
    
    public let havePurchase: Bool
    public init(
        havePurchase: Bool,
        onAvailableProduct: @escaping (() -> AnyPublisher<AppProduct, Error>),
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
    
    public func availableProduct() -> AnyPublisher<AppProduct, Error> {
        onAvailableProduct()
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
