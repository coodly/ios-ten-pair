import Dependencies
import Logging
import StoreKit
import UIKit
import XCTestDynamicOverlay

extension UserDefaults {
    fileprivate var eventCount: Int {
        get {
            integer(forKey: #function)
        }
        set {
            set(newValue, forKey: #function)
        }
    }
    fileprivate var askedVersion: String {
        get {
            string(forKey: #function) ?? ""
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
        if currentAppVersion == UserDefaults.standard.askedVersion {
            return
        }
        
        resetEvents()
        UserDefaults.standard.synchronize()
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
                
        if currentAppVersion == UserDefaults.standard.askedVersion {
            return
        }
        
        UserDefaults.standard.askedVersion = currentAppVersion
        SKStoreReviewController.requestReview()
    }
    
    public func rateAppManual() {
        UIApplication.shared.open(URL(string: "https://apps.apple.com/app/id837173458?action=write-review")!, options: [:])
    }
    
    private func resetEvents() {
        UserDefaults.standard.eventCount = 0
    }
    
    private var currentAppVersion: String {
        let infoDictionaryKey = kCFBundleVersionKey as String
        return Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String ?? "-"
    }
}

extension RateAppClient {
    public static let client = RateAppClient()
}

extension RateAppClient: DependencyKey {
    public static var liveValue: RateAppClient {
        RateAppClient()
    }
}

extension DependencyValues {
    public var rateAppClient: RateAppClient {
        get { self[RateAppClient.self] }
        set { self[RateAppClient.self] = newValue }
    }
}
