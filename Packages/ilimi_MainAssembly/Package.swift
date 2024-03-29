// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ilimiMainAssembly",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ilimiMainAssembly",
            targets: ["ilimiMainAssembly"]
        ),
        .library(
            name: "IMKCandidatesImpl",
            targets: ["IMKCandidatesImpl"]
        ),
    ],
    dependencies: [
        .package(path: "../vChewing_IMKUtils_IlimiImpl"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ilimiMainAssembly",
            dependencies: [
                "IOKitCHeaders",
                "IMKCandidatesImpl",
                .product(name: "vChewing_IMKUtils_IlimiImpl", package: "vChewing_IMKUtils_IlimiImpl"),
            ],
            resources: [
                .process("Resources/Model.xcdatamodeld"),
            ]
        ),
        .target(
            name: "IOKitCHeaders",
            resources: []
        ),
        .target(
            name: "IMKCandidatesImpl",
            resources: []
        ),
        .testTarget(
            name: "ilimiMainAssemblyTests",
            dependencies: ["ilimiMainAssembly"]
        ),
    ]
)
