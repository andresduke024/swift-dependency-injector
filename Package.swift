// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftDependencyInjector",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(
            name: "SwiftDependencyInjector",
            targets: ["swift-dependency-injector"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "swift-dependency-injector",
            dependencies: []),
        .testTarget(
            name: "swift-dependency-injectorTests",
            dependencies: ["swift-dependency-injector"])
    ]
)
