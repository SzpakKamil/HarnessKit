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
            path: "Sources/HarnessKitScreenshots"
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
                    condition: .when(platforms: [.macOS, .iOS, .visionOS])
                )
            ],
            path: "SwiftPM-PlatformExclude/HarnessKitTransformWrap"
        ),
        .target(
            name: "HarnessKitTransform",
            dependencies: ["HarnessKitScreenshots"],
            path: "Sources/HarnessKitTransform",
            // `blur_ci.metalsrc` is extension-swapped (not `.metal`)
            // so Xcode's SPM resource pipeline doesn't try to compile
            // it as a stitchable Metal shader. `.process("Resources")`
            // picks up both the device JSON files and this raw source
            // and ships them as bundle resources; the CoreImage kernel
            // it defines is compiled at runtime via
            // `CIKernel.kernels(withMetalString:)` inside
            // `MetalProgressiveBlur.swift`, which is where the
            // `-fcikernel` flag `coreimage::sampler` needs gets
            // applied.
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "HarnessKitTests",
            dependencies: ["HarnessKit", "HarnessKitTesting"]
        ),
        .testTarget(
            name: "HarnessKitTransformTests",
            dependencies: [
                "HarnessKitTransform",
                .target(name: "HarnessKitScreenshotTesting", condition: .when(platforms: [.macOS])),
            ]
        )
    ]
)
