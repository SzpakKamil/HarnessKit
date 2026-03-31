//
//  MaskScreenshot.swift
//  HarnessKitTransform
//

import Foundation
import AppKit

public nonisolated func maskScreenshot(image: NSImage, bezel: any BezelDescriptor) -> NSImage {
    guard
        let maskImage = try? bezel.maskImage(),
        let sourceCGImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil),
        let maskSourceCG = maskImage.cgImage(forProposedRect: nil, context: nil, hints: nil)
    else {
        return image
    }

    let width = Int(image.size.width)
    let height = Int(image.size.height)

    let grayColorSpace = CGColorSpaceCreateDeviceGray()

    guard let maskContext = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: grayColorSpace,
        bitmapInfo: CGImageAlphaInfo.none.rawValue
    ) else {
        return image
    }

    maskContext.draw(
        maskSourceCG,
        in: CGRect(x: 0, y: 0, width: width, height: height)
    )

    guard
        let maskCGImage = maskContext.makeImage(),
        let cgMask = CGImage(
            maskWidth: maskCGImage.width,
            height: maskCGImage.height,
            bitsPerComponent: maskCGImage.bitsPerComponent,
            bitsPerPixel: maskCGImage.bitsPerPixel,
            bytesPerRow: maskCGImage.bytesPerRow,
            provider: maskCGImage.dataProvider!,
            decode: [1, 0],
            shouldInterpolate: false
        ),
        let maskedCGImage = sourceCGImage.masking(cgMask)
    else {
        return image
    }

    return NSImage(cgImage: maskedCGImage, size: image.size)
}
