// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "HarnessKit",
    platforms: [
        // `[[stitchable]]` Metal functions in `Resources/blur.metal`
        // need Metal 2.4, which ships with macOS 12 / iOS 15. Older
        // OS targets fall back to the `ProgressiveBlurCompatModifier`
        // SwiftUI path (native `.blur(radius:) + .mask(gradient)`)
        // and, on the export side, the pre-Metal `gaussianBlur +
        // blendWithMaskCI` path gated by the `#available` check in
        // `Renderer+Effects.swift`.
        .iOS(.v15), .tvOS(.v15), .visionOS(.v1), .macOS(.v12), .watchOS(.v10)
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
