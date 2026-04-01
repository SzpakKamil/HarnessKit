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
        .library(
            name: "HarnessKitScreenshots",
            targets: ["HarnessKitScreenshots"]
        ),
        .library(
            name: "HarnessKitScreenshotTesting",
            targets: ["HarnessKitScreenshotTesting"]
        ),
        .library(
            name: "HarnessKitTransform",
            targets: ["HarnessKitTransformTarget"]
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
            path: "Sources/HarnessKitScreenshots",
            resources: [.process("Resources")]
        ),
        .target(
            name: "HarnessKitScreenshotTesting",
            dependencies: ["HarnessKitScreenshots"],
            path: "Sources/HarnessKitScreenshotTesting"
        ),
        .target(
            name: "HarnessKitTransformTarget",
            dependencies: [
                .target(
                    name: "HarnessKitTransform",
                    condition: .when(platforms: [.macOS])
                )
            ],
            path: "SwiftPM-PlatformExclude/HarnessKitTransformWrap"
        ),
        .target(
            name: "HarnessKitTransform",
            dependencies: ["HarnessKitScreenshots"],
            path: "Sources/HarnessKitTransform",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "HarnessKitTests",
            dependencies: ["HarnessKit", "HarnessKitTesting"]
        )
    ]
)
