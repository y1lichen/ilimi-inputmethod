// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "vChewing_IMKUtils_IlimiImpl",
    platforms: [
        .macOS(.v11),
    ],
    products: [
        .library(
            name: "vChewing_IMKUtils_IlimiImpl",
            targets: ["IMKUtils"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "IMKUtils",
            dependencies: []
        ),
    ]
)
