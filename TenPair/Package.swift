// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TenPair",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "TenPair",
            targets: ["TenPair"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        //.package(path: "../../swift-give-me-ads"),
    ],
    targets: [
        .target(
            name: "TenPair",
            dependencies: []),
        .testTarget(
            name: "TenPairTests",
            dependencies: ["TenPair"]),
    ]
)
