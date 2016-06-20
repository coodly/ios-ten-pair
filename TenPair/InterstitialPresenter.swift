/*
 * Copyright 2016 Coodly LLC
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

import Foundation

protocol InterstitialPresenter: class, FullVersionHandler, InterstitialCounter {
    #if os(iOS)
    var interstitial: GADInterstitial? { get set }
    #endif
    func loadInterstitial()
    func presentInterstitial()
}

#if os(iOS)
import UIKit
import GoogleMobileAds
import SWLogger

extension InterstitialPresenter where Self: UIViewController {
    func loadInterstitial() {
        Log.debug("loadInterstitial")
        
        interstitial = GADInterstitial(adUnitID: AdMobInterstitialUnit)
        
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        interstitial!.loadRequest(request)
    }
    
    func presentInterstitial() {
        if fullVersionUnlocked() {
            return
        }
        
        guard let presented = interstitial else {
            Log.debug("No interstitial")
            return
        }
        
        guard presented.isReady else {
            Log.debug("Not ready")
            return
        }
        
        guard showCalled() else {
            Log.debug("Don't show yet")
            return
        }
        
        presented.presentFromRootViewController(self)
    }
}
#else
    extension InterstitialPresenter {
        func loadInterstitial() {
            
        }
        
        func presentInterstitial() {
            
        }
    }
#endif
