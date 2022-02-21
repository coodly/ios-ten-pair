import PurchaseFeature
import RestartFeature
import Themes

public struct MenuState: Equatable {
    public var purchaseState: PurchaseState?
    public var restartState: RestartState?
    
    public var activeThemeName: String
    
    public init(havePurchase: Bool) {
        activeThemeName = AppTheme.shared.active.localizedName
        purchaseState = havePurchase ? PurchaseState() : nil
    }
}
