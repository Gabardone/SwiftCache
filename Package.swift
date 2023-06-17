// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftCache",
    platforms: [
        // Minimum deployment version currently set by `Logger` release version.
        .iOS(.v14),
        .macOS(.v12),
        .macCatalyst(.v14),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "SwiftCache",
            targets: ["SwiftCache"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Gabardone/NetworkDependency.git", from: "1.0.1")
    ],
    targets: [
        .target(
            name: "SwiftCache",
            dependencies: ["NetworkDependency"]
        ),
        .testTarget(
            name: "SwiftCacheTests",
            dependencies: ["NetworkDependency", "SwiftCache"]
        )
    ]
)
