import PurchaseFeature
import RestartFeature
import SendFeedbackFeature
import Themes

public struct MenuState: Equatable {
    public var purchaseState: PurchaseReducer.State?
    public var restartState: RestartState?
    public var sendFeedbackState: SendFeedbackState?
    
    public var activeThemeName: String
    public let feedbackEnabled: Bool
    public var haveUnreadMessage = false
    
    public init(feedbackEnabled: Bool, havePurchase: Bool) {
        activeThemeName = AppTheme.shared.active.localizedName
        purchaseState = havePurchase ? PurchaseReducer.State() : nil
        self.feedbackEnabled = feedbackEnabled
    }
}
