// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

private let composable = Target.Dependency.product(name: "ComposableArchitecture", package: "swift-composable-architecture")

let package = Package(
    name: "TenPair",
    defaultLocalization: LanguageTag("en"),
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(
            name: "AppPackages",
            targets: [
                "ApplicationFeature",
                "Localization"
            ]
        ),
        .library(
            name: "MobilePackages",
            targets: [
                "AppLaunchMobile",
                "MobileAdsClientLive",
                "PurchaseClientLive"
            ]
        ),
        .library(
            name: "DesktopPackages",
            targets: [
                "AppLaunchDesktop"
            ]
        ),

        .library(
            name: "Config",
            targets: ["Config"]),
        .library(
            name: "FeedbackClient",
            targets: ["FeedbackClient"]),
        .library(
            name: "Logging",
            targets: ["Logging"]),
        .library(
            name: "Play",
            targets: ["Play"]),
        .library(
            name: "RandomLines",
            targets: ["RandomLines"]),
        .library(
            name: "Save",
            targets: ["Save"]),
    ],
    dependencies: [
        .package(name: "SWLogger", url: "https://github.com/coodly/swlogger.git", from: "0.6.1"),
        .package(name: "Purchases", url: "https://github.com/RevenueCat/purchases-ios.git", from: "3.14.1"),
        
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "0.33.1")
    ],
    targets: [
        .binaryTarget(
            name: "GoogleAppMeasurement",
            path: "Thirdparty/Google-Mobile-Ads-SDK/9.0.0/GoogleAppMeasurement.xcframework"
        ),
        .binaryTarget(
            name: "GoogleAppMeasurementIdentitySupport",
            path: "Thirdparty/Google-Mobile-Ads-SDK/9.0.0/GoogleAppMeasurementIdentitySupport.xcframework"
        ),
        .binaryTarget(
            name: "GoogleMobileAds",
            path: "Thirdparty/Google-Mobile-Ads-SDK/9.0.0/GoogleMobileAds.xcframework"
        ),
        .binaryTarget(
            name: "GoogleUtilities",
            path: "Thirdparty/Google-Mobile-Ads-SDK/9.0.0/GoogleUtilities.xcframework"
        ),
        .binaryTarget(
            name: "nanopb",
            path: "Thirdparty/Google-Mobile-Ads-SDK/9.0.0/nanopb.xcframework"
        ),
        .binaryTarget(
            name: "PromisesObjC",
            path: "Thirdparty/Google-Mobile-Ads-SDK/9.0.0/PromisesObjC.xcframework"
        ),
        .binaryTarget(
            name: "UserMessagingPlatform",
            path: "Thirdparty/Google-Mobile-Ads-SDK/9.0.0/UserMessagingPlatform.xcframework"
        ),
        
        .target(
            name: "AdsPresentationFeature",
            dependencies: [
                "AppAdsFeature",
                "Autolayout",
                "Storyboards",
                "Themes"
            ],
            resources: [.process("Resources")]
        ),
        .target(
            name: "AppAdsFeature",
            dependencies: [
                composable
            ]
        ),
        .target(
            name: "AppLaunchDesktop",
            dependencies: [
                "ApplicationFeature",
                "Autolayout",
                "PlayPresentationFeature"
            ]
        ),
        .target(
            name: "AppLaunchMobile",
            dependencies: [
                "AdsPresentationFeature",
                "ApplicationFeature",
                "Autolayout",
                "PlayPresentationFeature"
            ]
        ),
        .target(
            name: "ApplicationFeature",
            dependencies: [
                "AppAdsFeature",
                "Logging",
                "MobileAdsClient",
                "PlayFeature",
                "PurchaseFeature",
                "PurchaseClient",
                
                composable
            ]
        ),
        .target(
            name: "Autolayout"
        ),
        .target(
            name: "Config"
        ),
        .target(
            name: "FeedbackClient"
        ),
        .target(
            name: "LoadingPresentation",
            dependencies: [
                "Storyboards",
                "UIComponents",
            ],
            resources: [.process("Resources")]
        ),
        .target(
            name: "Localization",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Logging",
            dependencies: [
                "Config",
                "SWLogger"
            ]
        ),
        .target(
            name: "MenuFeature",
            dependencies: [
                "PurchaseFeature",
                "RestartFeature",
                "Themes",
                
                composable
            ]
        ),
        .target(
            name: "MenuPresentation",
            dependencies: [
                "Autolayout",
                "Localization",
                "MenuFeature",
                "Purchase",
                "Storyboards",
                "UIComponents"
            ],
            resources: [.process("Resources")]
        ),
        .target(
            name: "MobileAdsClient"
        ),
        .target(
            name: "MobileAdsClientLive",
            dependencies: [
                "MobileAdsClient",
                
                "GoogleAppMeasurement",
                "GoogleAppMeasurementIdentitySupport",
                "GoogleMobileAds",
                "GoogleUtilities",
                "nanopb",
                "PromisesObjC",
                "UserMessagingPlatform"
            ]
        ),
        .target(
            name: "Play",
            dependencies: [
                "Config",
                "Save"
            ]
        ),
        .target(
            name: "PlayFeature",
            dependencies: [
                "MenuFeature",
                "PlaySummaryFeature",
                
                composable
            ]
        ),
        .target(
            name: "PlayPresentationFeature",
            dependencies: [
                "LoadingPresentation",
                "MenuPresentation",
                "Play",
                "PlayFeature",
                "Purchase",
                "RandomLines",
                "Save",
                "Storyboards",
                "Themes",
                "WinPresentation"
            ],
            resources: [.process("Resources")]
        ),
        .target(
            name: "PlaySummaryFeature",
            dependencies: [
                "Themes",
                
                composable
            ]
        ),
        .target(
            name: "Purchase",
            dependencies: [
                "Localization",
                "RemoveAds"
            ]
        ),
        .target(
            name: "PurchaseClient"
        ),
        .target(
            name: "PurchaseClientLive",
            dependencies: [
                "Config",
                "Logging",
                "PurchaseClient",
                "Purchases"
            ]
        ),
        .target(
            name: "PurchaseFeature",
            dependencies: [
                composable
            ]
        ),
        .target(
            name: "RandomLines",
            dependencies: [
                "Config",
                "Play",
                "Save"
            ]
        ),
        .target(
            name: "RemoveAds"
        ),
        .target(
            name: "RemoveAdsImpl",
            dependencies: [
                "Config",
                "Logging",
                "Purchases",
                "RemoveAds"
            ]
        ),
        .target(
            name: "RestartFeature",
            dependencies: [
                composable
            ]
        ),
        .target(
            name: "Save",
            dependencies: [
                "Config"
            ]
        ),
        .target(
            name: "Storyboards"
        ),
        .target(
            name: "UIComponents",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Themes",
            dependencies: [
                "Localization",
                "UIComponents"
            ]
        ),
        .target(
            name: "WinPresentation",
            dependencies: [
                "Autolayout",
                "Storyboards",
                "Themes"
            ],
            resources: [.process("Resources")]
        ),

        .testTarget(
            name: "PlayTests",
            dependencies: ["Play"]),
        .testTarget(
            name: "RandomLinesTests",
            dependencies: ["RandomLines"]),
    ]
)
