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

import AppLaunchMobile
import ApplicationFeature
import AVKit
import CloudMessagesClient
import CloudMessagesClientLive
import ComposableArchitecture
import Config
import Logging
import MobileAdsClient
import MobileAdsClientLive
import PurchaseClient
import PurchaseClientLive
import RateAppClient
import Themes
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    @Dependency(\.purchaseClient) var purchaseClient
    
    private lazy var store = Store(
        initialState: Application.State(),
        reducer: Application.init
    )

    private lazy var viewStore = ViewStore(store, observe: { $0 })

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppTheme.shared.load()
                        
        Log.enable()
                        
        if purchaseClient.havePurchase {
            purchaseClient.load()
        }

        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
        
        let launch = window!.rootViewController as! MobileLaunchViewController
        launch.store = store
        
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        viewStore.send(.onDidBecomeActive)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: .saveField, object: nil)
    }
}

