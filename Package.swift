// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "HarnessKit",
    platforms: [
        .iOS(.v17), .tvOS(.v17), .visionOS(.v1), .macOS(.v14), .watchOS(.v10)
    ],
    products: [
        .library(
            name: "HarnessKit",
            targets: ["HarnessKit"]
        ),
        .library(
            name: "HarnessKitTesting",
            targets: ["HarnessKitTesting"]
        ),
    ],
    targets: [
        .target(
            name: "HarnessKit"
        ),
        .target(
            name: "HarnessKitTesting",
            dependencies: ["HarnessKit"]
        ),
        .testTarget(
            name: "HarnessKitTests",
            dependencies: ["HarnessKit", "HarnessKitTesting"]
        )
    ]
)
