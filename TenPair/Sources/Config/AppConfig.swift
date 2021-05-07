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

import Foundation

public let DefaultStartBoard = [
    1, 2, 3, 4, 5, 6, 7, 8, 9,
    1, 1, 1, 2, 1, 3, 1, 4, 1,
    5, 1, 6, 1, 7, 1, 8, 1, 9
]

public let NumberOfColumns = 9
public let AdAfterLines = 10

private let ReleaseBuild = false

public struct AdUnits {
    public let banner: String
    public let interstitial: String
    static let live = AdUnits(banner: AdMobBannerUnit, interstitial: AdMobInterstitial)
    static let demo = AdUnits(banner: DemoAdMobBannerUnit, interstitial: DemoInterstitial)
}

public struct AppConfig {
    public let logs = !ReleaseBuild
    public let ads: Bool
    public let adUnits = ReleaseBuild ? AdUnits.live : AdUnits.demo
    let showDebugInfo = !ReleaseBuild
    
    public static let current = AppConfig(ads: true)
}

extension Notification.Name {
    public static let saveField = Notification.Name(rawValue: "TenPairSaveField")
    public static let hintTaken = Notification.Name(rawValue: "TenPairHintTaken")
    public static let fieldReload = Notification.Name(rawValue: "TenPairFieldReload")
}
