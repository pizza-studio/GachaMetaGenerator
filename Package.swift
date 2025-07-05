// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GachaMetaGenerator",
    platforms: [.iOS(.v13), .macOS(.v10_15), .macCatalyst(.v13), .watchOS(.v6), .visionOS(.v1)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GachaMetaGeneratorModule",
            targets: ["GachaMetaGeneratorModule"]
        ),
        .library(
            name: "GachaMetaDB",
            targets: ["GachaMetaDB"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "GachaMetaGenerator",
            dependencies: [
                "GachaMetaGeneratorModule",
            ]
        ),
        .target(
            name: "GachaMetaGeneratorModule"
        ),
        .target(
            name: "GachaMetaDB",
            dependencies: ["GachaMetaGeneratorModule"],
            resources: [
                .process("Resources/"),
            ]
        ),
        .testTarget(
            name: "GachaMetaGeneratorTests",
            dependencies: ["GachaMetaGeneratorModule"]
        ),
        .testTarget(
            name: "GachaMetaDBTests",
            dependencies: ["GachaMetaDB"]
        ),
    ]
)
