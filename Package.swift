// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "HarnessKit",
    platforms: [
        .iOS(.v14), .tvOS(.v14), .visionOS(.v1), .macOS(.v11), .watchOS(.v10)
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
