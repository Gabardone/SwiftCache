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
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftCache",
            targets: ["SwiftCache"]
        ),
        .library(
            name: "SwiftCacheTesting",
            targets: ["SwiftCacheTesting"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Gabardone/NetworkDependency.git", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SwiftCache",
            dependencies: ["NetworkDependency"]
        ),
        .target(
            name: "SwiftCacheTesting",
            dependencies: ["SwiftCache"]
        ),
        .testTarget(
            name: "SwiftCacheTests",
            dependencies: ["NetworkDependency", "SwiftCache", "SwiftCacheTesting"]
        )
    ]
)
