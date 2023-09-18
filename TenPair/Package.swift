// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

private let composable = Target.Dependency.product(name: "ComposableArchitecture", package: "swift-composable-architecture")
private let dependencies = Target.Dependency.product(name: "Dependencies", package: "swift-dependencies")
private let testOverlay = Target.Dependency.product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")

private let withConcurrencyFlags = [
    .enableUpcomingFeature("BareSlashRegexLiterals"),
    .enableUpcomingFeature("ConciseMagicFile"),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("ForwardTrailingClosures"),
    .enableUpcomingFeature("ImplicitOpenExistentials"),
    .enableUpcomingFeature("StrictConcurrency"),
    SwiftSetting.unsafeFlags(
        [
            "-Xfrontend",
            "-warn-long-function-bodies=100",
            "-Xfrontend",
            "-warn-long-expression-type-checking=100",
            "-Xfrontend",
            "-warn-concurrency",
            "-Xfrontend",
            "-enable-actor-data-race-checks"
        ]
    )
]

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
                "CloudMessagesClientLive",
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
        .package(url: "https://github.com/coodly/swlogger.git", exact: "0.6.1"),
        .package(url: "https://github.com/RevenueCat/purchases-ios.git", exact: "3.14.1"),
        
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", exact: "1.2.0"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.0.2"),
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
                "Logging",
                
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
                "CloudMessagesClient",
                "Logging",
                "MobileAdsClient",
                "PlayFeature",
                "PurchaseClient",
                "RateAppClient",
                
                composable
            ]
        ),
        .target(
            name: "Autolayout"
        ),
        .target(
            name: "CloudMessagesClient",
            dependencies: [
                dependencies,
                testOverlay
            ]
        ),
        .target(
            name: "CloudMessagesClientLive",
            dependencies: [
                "CloudMessagesClient",
                "Logging"
            ]
        ),
        .target(
            name: "Config"
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
            resources: [.process("Resources")],
            swiftSettings: []
        ),
        .target(
            name: "Logging",
            dependencies: [
                "Config",
                
                .product(name: "SWLogger", package: "swlogger")
            ]
        ),
        .target(
            name: "MenuFeature",
            dependencies: [
                "PurchaseFeature",
                "RestartFeature",
                "SendFeedbackFeature",
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
                "Storyboards",
                "UIComponents"
            ],
            resources: [.process("Resources")]
        ),
        .target(
            name: "MobileAdsClient",
            dependencies: [
                dependencies,
                testOverlay
            ]
        ),
        .target(
            name: "MobileAdsClientLive",
            dependencies: [
                "Config",
                "Logging",
                "MobileAdsClient",
                
                "GoogleAppMeasurement",
                "GoogleAppMeasurementIdentitySupport",
                "GoogleMobileAds",
                "GoogleUtilities",
                "nanopb",
                "PromisesObjC",
                "UserMessagingPlatform"
            ],
            swiftSettings: []
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
                "RandomLines",
                "Save",
                "Storyboards",
                "Themes",
                "WinPresentation"
            ],
            resources: [.process("Resources")],
            swiftSettings: []
        ),
        .target(
            name: "PlaySummaryFeature",
            dependencies: [
                "Themes",
                
                composable
            ]
        ),
        .target(
            name: "PurchaseClient",
            dependencies: [
                dependencies,
                testOverlay
            ]
        ),
        .target(
            name: "PurchaseClientLive",
            dependencies: [
                "Config",
                "Logging",
                "PurchaseClient",
                
                .product(name: "Purchases", package: "purchases-ios")
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
            name: "RateAppClient",
            dependencies: [
                "Logging",
                
                dependencies,
                testOverlay
            ],
            swiftSettings: []
        ),
        .target(
            name: "RemoveAds"
        ),
        .target(
            name: "RemoveAdsImpl",
            dependencies: [
                "Config",
                "Logging",
                "RemoveAds",
                
                .product(name: "Purchases", package: "purchases-ios")
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
            name: "SendFeedbackFeature",
            dependencies: [
                "Autolayout",
                "CloudMessagesClient",
                "Localization",
                "Storyboards",
                
                composable
            ],
            resources: [.process("Resources")]
        ),
        .target(
            name: "Storyboards",
            swiftSettings: []
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
            ],
            swiftSettings: []
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
    .map { (target: Target) in
        if target.type == .binary {
            return target
        }
        
        guard target.swiftSettings == nil else {
            return target
        }
        
        target.swiftSettings = withConcurrencyFlags
        return target
    }
)
