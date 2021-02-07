/*
* Copyright 2017 Coodly LLC
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import UIKit
import PersonalizedAdConsent

extension Notification.Name {
    public static let personalizedAdsStatusChanged = Notification.Name(rawValue: "com.coodly.stocked.personalized.ads")
}

internal class AdMobGDPRCheck: PersonalizedAdsCheck {
    internal weak var showOn: UIViewController?
    
    var showGDPRConsentMenuItem: Bool {
        PACConsentInformation.sharedInstance.isRequestLocationInEEAOrUnknown
    }
    
    var canShowPersonalizedAds: Bool {
        if !PACConsentInformation.sharedInstance.isRequestLocationInEEAOrUnknown {
            return true
        }
        
        return PACConsentInformation.sharedInstance.consentStatus == .personalized
    }
    
    private var personalizedStatus = PACConsentInformation.sharedInstance.consentStatus {
        didSet {
            guard oldValue != personalizedStatus else {
                return
            }
            
            NotificationCenter.default.post(name: .personalizedAdsStatusChanged, object: nil)
        }
    }
    
    func check() {
        Log.ads.debug("Check AdMob consent")
        PACConsentInformation.sharedInstance.requestConsentInfoUpdate(forPublisherIdentifiers: [AdMobPulisherIdentifier]) {
            error in
            
            if let error = error {
                Log.ads.error("Check consent error: \(error)")
            } else {
                Log.ads.debug("Consent status: \(PACConsentInformation.sharedInstance.consentStatus)")
                Log.ads.debug("Consent needed?: \(PACConsentInformation.sharedInstance.isRequestLocationInEEAOrUnknown)")
            }
        }
    }
    
    func present() {
        guard let privacyUrl = URL(string: "https://www.coodly.com/tenpair/privacy"),
            let form = PACConsentForm(applicationPrivacyPolicyURL: privacyUrl) else {
                print("incorrect privacy URL.")
                return
        }
        form.shouldOfferPersonalizedAds = true
        form.shouldOfferNonPersonalizedAds = true
        form.shouldOfferAdFree = false
        
        form.load() {
            error in
            
            if let error = error {
                Log.ads.error("Load form error: \(error)")
            } else {
                form.present(from: self.showOn!) {
                    error, adFree in
                    
                    if let error = error {
                        Log.ads.error("Consent result error: \(error)")
                    } else {
                        Log.ads.debug("Consent status: \(PACConsentInformation.sharedInstance.consentStatus)")
                        self.personalizedStatus = PACConsentInformation.sharedInstance.consentStatus
                    }
                }
            }
        }
    }
}

extension PACConsentStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            return "unknown"
        case .nonPersonalized:
            return "nonPersonalized"
        case .personalized:
            return "personalized"
        @unknown default:
            return "unknown-\(self)"
        }
    }
}
