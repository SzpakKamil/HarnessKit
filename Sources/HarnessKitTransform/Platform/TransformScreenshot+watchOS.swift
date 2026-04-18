import HarnessKitScreenshots

nonisolated func processScreenshotWatchOS(image: PlatformImage, config: ScreenshotConfig, screenshot: Screenshot) throws -> PlatformImage {
    guard let matched = config.matchedBezel(for: screenshot) else {
        throw TransformError.bezelNotFound(screenshotID: screenshot.id)
    }

    let descriptor: WatchDeviceDescriptor
    do {
        descriptor = try WatchDeviceDescriptor.descriptor(for: matched.deviceID)
    } catch {
        throw TransformError.bezelNotFound(screenshotID: screenshot.id)
    }

    if screenshot.addBezel {
        let bezelImage: PlatformImage
        do {
            bezelImage = try descriptor.bezelImage(color: matched.color, band: matched.band)
        } catch {
            throw TransformError.bezelImageMissing(bezelID: matched.deviceID)
        }
        let params = BezelPipelineParams(
            os: screenshot.os,
            bezelImage: bezelImage,
            scale: descriptor.scale,
            verticalOffset: descriptor.verticalOffset,
            horizontalOffset: descriptor.horizontalOffset,
            cornerRadius: descriptor.screenCornerRadius,
            screenshotOnTop: false
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
        scale: descriptor.scale
    )
}
