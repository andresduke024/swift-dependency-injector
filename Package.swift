// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftDependencyInjector",
    products: [
        .library(
            name: "SwiftDependencyInjector",
            targets: ["swift-dependency-injector"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "swift-dependency-injector",
            dependencies: []),
        .testTarget(
            name: "swift-dependency-injectorTests",
            dependencies: ["swift-dependency-injector"]),
    ]
)
