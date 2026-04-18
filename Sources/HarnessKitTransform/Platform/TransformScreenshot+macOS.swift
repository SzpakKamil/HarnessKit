import HarnessKitScreenshots

nonisolated func processScreenshotMacOS(image: PlatformImage, config: ScreenshotConfig, screenshot: Screenshot) throws -> PlatformImage {
    guard let matched = config.matchedBezel(for: screenshot) else {
        throw TransformError.bezelNotFound(screenshotID: screenshot.id)
    }

    let descriptor: MacDeviceDescriptor
    do {
        descriptor = try MacDeviceDescriptor.descriptor(for: matched.deviceID)
    } catch {
        throw TransformError.bezelNotFound(screenshotID: screenshot.id)
    }

    if screenshot.addBezel {
        // Extract major OS version string, e.g. "26.0" → "26"
        let osMajor = screenshot.osVersion
            .flatMap { $0.split(separator: ".").first.map(String.init) }
            ?? "15"

        let bezelImage: PlatformImage
        do {
            bezelImage = try descriptor.bezelImage(
                color: matched.color,
                osMajor: osMajor,
                wallpaperType: matched.wallpaperType,
                appearance: screenshot.appearance
            )
        } catch {
            throw TransformError.bezelImageMissing(bezelID: matched.deviceID)
        }

        let params = BezelPipelineParams(
            os: screenshot.os,
            bezelImage: bezelImage,
            scale: descriptor.scale,
            verticalOffset: descriptor.verticalOffset,
            horizontalOffset: descriptor.horizontalOffset,
            cornerRadius: 0,
            screenshotOnTop: true
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
