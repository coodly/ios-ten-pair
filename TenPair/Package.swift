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
            name: "Logging",
            targets: ["Logging"]),
        .library(
            name: "Play",
            targets: ["Play"]),
        .library(
            name: "Rendered",
            targets: ["Rendered"]),
        .library(
            name: "TenPair",
            targets: ["TenPair"]),
    ],
    dependencies: [
        //.package(path: "../../swift-give-me-ads"),
        .package(name: "SWLogger", url: "https://github.com/coodly/swlogger.git", from: "0.6.1"),
    ],
    targets: [
        .target(
            name: "Config"),
        .target(
            name: "Logging",
            dependencies: ["Config", "SWLogger"]),
        .target(
            name: "Play",
            dependencies: ["Config"]),
        .target(
            name: "Rendered"),
        .target(
            name: "TenPair",
            dependencies: []),

        .testTarget(
            name: "PlayTests",
            dependencies: ["Play"]),
        .testTarget(
            name: "TenPairTests",
            dependencies: ["TenPair"]),
    ]
)
