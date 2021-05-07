// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TenPair",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
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
        .library(
            name: "TenPair",
            targets: ["TenPair"]),
    ],
    dependencies: [
        //.package(path: "../../swift-give-me-ads"),
        .package(name: "SWLogger", url: "https://github.com/coodly/swlogger.git", from: "0.6.1"),
        .package(name: "Purchases", url: "https://github.com/RevenueCat/purchases-ios.git", from: "3.11.1"),
    ],
    targets: [
        .target(
            name: "Config"),
        .target(
            name: "FeedbackClient"),
        .target(
            name: "Logging",
            dependencies: ["Config", "SWLogger"]),
        .target(
            name: "Play",
            dependencies: ["Config", "Save"]),
        .target(
            name: "RandomLines",
            dependencies: ["Config", "Play", "Save"]),
        .target(name: "RemoveAds"),
        .target(name: "RemoveAdsImpl",
                dependencies: ["Config", "Logging", "Purchases", "RemoveAds"]
        ),
        .target(
            name: "Rendered"),
        .target(
            name: "Save",
            dependencies: ["Config"]),
        .target(
            name: "TenPair",
            dependencies: []),

        .testTarget(
            name: "PlayTests",
            dependencies: ["Play"]),
        .testTarget(
            name: "RandomLinesTests",
            dependencies: ["RandomLines"]),
        .testTarget(
            name: "TenPairTests",
            dependencies: ["TenPair"]),
    ]
)
