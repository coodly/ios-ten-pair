import Logging
import UIKit

public struct RateAppClient {
    public func appLaunch() {
        Log.rate.debug("App laucnh")
    }
    
    public func maybeRateEvent() {
        
    }
    
    public func rateAppManual() {
        UIApplication.shared.open(URL(string: "https://itunes.apple.com/us/app/appName/id837173458?mt=8&action=write-review")!, options: [:])
    }
}

extension RateAppClient {
    public static let client = RateAppClient()
}
