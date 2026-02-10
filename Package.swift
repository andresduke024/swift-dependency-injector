// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "SwiftDependencyInjector",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "SwiftDependencyInjector",
            targets: ["SwiftDependencyInjector"]
        ),
        .library(
            name: "SwiftDependencyInjectorMacros",
            targets: ["SwiftDependencyInjectorMacros"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/swiftlang/swift-syntax.git",
            from: "601.0.1"
        ),
    ],
    targets: [
        .target(
            name: "SwiftDependencyInjector",
            dependencies: [
                "SwiftDependencyInjectorMacros"
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .target(
            name: "SwiftDependencyInjectorMacros",
            dependencies: [
                "SwiftDependencyInjectorMacroImplementation",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftBasicFormat", package: "swift-syntax")
            ]
        ),
        .macro(
            name: "SwiftDependencyInjectorMacroImplementation",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftBasicFormat", package: "swift-syntax")
            ]
        ),
        .testTarget(
            name: "SwiftDependencyInjectorTests",
            dependencies: ["SwiftDependencyInjector"]
        )
    ]
)
