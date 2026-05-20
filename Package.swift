// swift-tools-version: 6.0

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
        .library(
            name: "HarnessKitScreenshots",
            targets: ["HarnessKitScreenshots"]
        ),
        .library(
            name: "HarnessKitScreenshotTesting",
            targets: ["HarnessKitScreenshotTesting"]
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
        .target(
            name: "HarnessKitScreenshots",
            path: "Sources/HarnessKitScreenshots"
        ),
        .target(
            name: "HarnessKitScreenshotTesting",
            dependencies: ["HarnessKitScreenshots"],
            path: "Sources/HarnessKitScreenshotTesting"
        ),
        .testTarget(
            name: "HarnessKitTests",
            dependencies: ["HarnessKit", "HarnessKitTesting"]
        ),
    ]
)
