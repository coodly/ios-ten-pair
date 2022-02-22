/*
 * Copyright 2020 Coodly LLC
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

import AppLaunchDesktop
import ApplicationFeature
import ComposableArchitecture
import FeedbackClient
import Logging
import MobileAdsClient
import PurchaseClient
import Themes
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    private lazy var store = Store(
        initialState: ApplicationState(),
        reducer: applicationReducer,
        environment: ApplicationEnvironment(
            adsClient: .noAds,
            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
            purchaseClient: .noPurchase
        )
    )
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppTheme.shared.load()
        
        Log.enable()
        
        FeedbackClient.active = .withoutFeedback
        
        let launch = window!.rootViewController as! DesktopLaunchViewController
        launch.store = store
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: .saveField, object: nil)
    }
}

