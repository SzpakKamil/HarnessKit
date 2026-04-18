import HarnessKitScreenshots

nonisolated func processScreenshotIOS(image: PlatformImage, config: ScreenshotConfig, screenshot: Screenshot) throws -> PlatformImage {
    let (descriptor, matched) = try resolveDeviceDescriptor(
        screenshot: screenshot, config: config, catalogue: DeviceDescriptor.allPhone
    )

    if screenshot.addBezel {
        let bezelImage = try loadBezelImage(descriptor: descriptor, matched: matched)
        let params = BezelPipelineParams(
            os: screenshot.os,
            bezelImage: bezelImage,
            scale: descriptor.scale,
            verticalOffset: descriptor.verticalOffset,
            horizontalOffset: descriptor.horizontalOffset,
            cornerRadius: descriptor.screenCornerRadius,
            screenshotOnTop: false,
            orientation: screenshot.orientation ?? config.phoneOrientation
        )
        let deviceImage = applyBezelPipeline(image: image, params: params)
        return renderDeviceOnCanvas(
            deviceImage: deviceImage,
            canvasSize: config.resolution.size,
            background: screenshot.background,
            shadows: screenshot.shadows,
            crop: screenshot.crop
        )
    }

    return applyNoBezelPipeline(
        image: image, screenshot: screenshot, config: config,
        scale: descriptor.scale,
        orientation: screenshot.orientation ?? config.phoneOrientation
    )
}
