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
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ilimiMainAssembly",
            dependencies: ["IMKCandidatesImpl"],
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