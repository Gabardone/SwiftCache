// swift-tools-version: 5.10
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
        .visionOS(.v1),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "SwiftCache",
            targets: ["SwiftCache"]
        )
    ],
    targets: [
        .target(
            name: "SwiftCache"
        ),
        .testTarget(
            name: "SwiftCacheTests",
            dependencies: ["SwiftCache"]
        )
    ]
)
