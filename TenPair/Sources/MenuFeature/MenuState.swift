import PurchaseFeature
import RestartFeature
import SendFeedbackFeature
import Themes

public struct MenuState: Equatable {
    public var purchaseState: Purchase.State?
    public var restartState: Restart.State?
    public var sendFeedbackState: SendFeedbackState?
    
    public var activeThemeName: String
    public let feedbackEnabled: Bool
    public var haveUnreadMessage = false
    
    public init(feedbackEnabled: Bool, havePurchase: Bool) {
        activeThemeName = AppTheme.shared.active.localizedName
        purchaseState = havePurchase ? Purchase.State() : nil
        self.feedbackEnabled = feedbackEnabled
    }
}
