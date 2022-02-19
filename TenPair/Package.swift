// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

private let composable = Target.Dependency.product(name: "ComposableArchitecture", package: "swift-composable-architecture")

let package = Package(
    name: "TenPair",
    defaultLocalization: LanguageTag("en"),
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .executable(
            name: "RandomSeeds",
            targets: ["RandomSeeds"]),
        
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
            name: "RemoveAds",
            targets: ["RemoveAds"]),
        .library(
            name: "RemoveAdsImpl",
            targets: ["RemoveAdsImpl"]),
        .library(
            name: "Rendered",
            targets: ["Rendered"]),
        .library(
            name: "Save",
            targets: ["Save"]),
    ],
    dependencies: [
        .package(name: "SWLogger", url: "https://github.com/coodly/swlogger.git", from: "0.6.1"),
        .package(name: "Purchases", url: "https://github.com/RevenueCat/purchases-ios.git", from: "3.11.1"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.3"),
        
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "0.33.1")
    ],
    targets: [
        .target(
            name: "AdsPresentationFeature",
            dependencies: [
                "AppAdsFeature",
                "Autolayout",
                "Storyboards"
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
            name: "Play",
            dependencies: [
                "Config",
                "Save"
            ]
        ),
        .target(
            name: "PlayFeature",
            dependencies: [
                "PlaySummaryFeature",
                
                composable
            ]
        ),
        .target(
            name: "PlayPresentationFeature",
            dependencies: [
                "PlayFeature",
                "Storyboards"
            ],
            resources: [.process("Resources")]
        ),
        .target(
            name: "PlaySummaryFeature",
            dependencies: [
                composable
            ]
        ),
        .target(
            name: "PurchaseClient"
        ),
        .target(
            name: "PurchaseClientLive",
            dependencies: [
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
            dependencies: ["Config", "Play", "Save"]),
        .target(name: "RemoveAds"),
        .target(name: "RemoveAdsImpl",
                dependencies: ["Config", "Logging", "Purchases", "RemoveAds"]
        ),
        .target(
            name: "RandomSeeds",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "RandomLines",
                "SWLogger",
            ]
        ),
        .target(
            name: "Rendered"
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

        .testTarget(
            name: "PlayTests",
            dependencies: ["Play"]),
        .testTarget(
            name: "RandomLinesTests",
            dependencies: ["RandomLines"]),
    ]
)
