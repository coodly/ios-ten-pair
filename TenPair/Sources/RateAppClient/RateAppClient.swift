import Logging
import StoreKit
import UIKit

extension UserDefaults {
    fileprivate var eventCount: Int {
        get {
            integer(forKey: #function)
        }
        set {
            set(newValue, forKey: #function)
        }
    }
}

private let TriggerRateCount = 5

public struct RateAppClient {
    public func appLaunch() {
        Log.rate.debug("App laucnh")
    }
    
    public func maybeRateEvent() {
        Log.rate.debug("Maybe rate")
        defer {
            UserDefaults.standard.synchronize()
        }
        UserDefaults.standard.eventCount += 1
        Log.rate.debug("Event count: \(UserDefaults.standard.eventCount)")
        if UserDefaults.standard.eventCount < TriggerRateCount {
            return
        }
        
        resetEvents()
        SKStoreReviewController.requestReview()
    }
    
    public func rateAppManual() {
        UIApplication.shared.open(URL(string: "https://apps.apple.com/app/id837173458?action=write-review")!, options: [:])
    }
    
    private func resetEvents() {
        UserDefaults.standard.eventCount = 0
    }
}

extension RateAppClient {
    public static let client = RateAppClient()
}
