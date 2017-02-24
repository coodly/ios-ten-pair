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
import GoogleMobileAds
import LaughingAdventure

class AdLoadingView: UIView, GADNativeExpressAdViewDelegate {
    private lazy var adView: GADNativeExpressAdView = {
        let gadView = GADNativeExpressAdView(adSize: GADAdSizeFromCGSize(CGSize(width: 320, height: 240)))!
        gadView.adUnitID = AdMobAdUnitID
        gadView.delegate = self
        //gadView.delegate = self
        // |-(
        gadView.rootViewController = UIApplication.shared.keyWindow?.rootViewController
        gadView.translatesAutoresizingMaskIntoConstraints = false
        gadView.isHidden = true
        return gadView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        add(fullSized: adView)
        DispatchQueue.main.async {
            self.loadAd()
        }
    }
    
    private func loadAd() {
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        adView.load(request)
    }
    
    public func nativeExpressAdViewDidReceiveAd(_ nativeExpressAdView: GADNativeExpressAdView) {
        Log.debug("Did receive ad")
        adView.isHidden = false
    }
    
    public func nativeExpressAdView(_ nativeExpressAdView: GADNativeExpressAdView, didFailToReceiveAdWithError error: GADRequestError) {
        Log.debug("Failed to receive ad: \(error)")
        adView.isHidden = true
    }
}
