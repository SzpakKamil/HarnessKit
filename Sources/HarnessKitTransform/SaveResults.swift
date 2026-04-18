import Foundation
import HarnessKitScreenshots

public nonisolated func saveResults(image: PlatformImage, screenshot: Screenshot, to directory: URL) throws {
    let fileManager = FileManager.default

    do {
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
    } catch {
        throw TransformError.outputDirectoryUnavailable(directory, error)
    }

    let fileName = screenshot.prettyName() + ".png"
    let fileURL = directory.appendingPathComponent(fileName)

    guard let cg = cgImage(from: image) else {
        throw TransformError.imageSaveFailed(fileURL, NSError(
            domain: "HarnessKitTransform", code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Image could not be converted to CGImage"]
        ))
    }

    do {
        try ScreenshotMetadata.write(cgImage: cg, screenshot: screenshot, to: fileURL)
    } catch {
        throw TransformError.imageSaveFailed(fileURL, error)
    }
}
