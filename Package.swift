// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftDependencyInjector",
    platforms: [.iOS(.v13), .macOS(.v10_15), .watchOS(.v7)],
    products: [
        .library(
            name: "SwiftDependencyInjector",
            targets: ["SwiftDependencyInjector"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftDependencyInjector",
            dependencies: []),
        .testTarget(
            name: "SwiftDependencyInjectorTests",
            dependencies: ["SwiftDependencyInjector"])
    ]
)
