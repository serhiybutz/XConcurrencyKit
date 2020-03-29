// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "XConcurrencyKit",
    platforms: [
        .iOS(.v12), .macOS(.v10_14), .tvOS(.v12), .watchOS(.v5)
    ],
    products: [
        .library(
            name: "XConcurrencyKit",
            targets: ["XConcurrencyKit"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "XConcurrencyKit",
            dependencies: []),
        .testTarget(
            name: "XConcurrencyKitTests",
            dependencies: ["XConcurrencyKit"]),
    ]
)
