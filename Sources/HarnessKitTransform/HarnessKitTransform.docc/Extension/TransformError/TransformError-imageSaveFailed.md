# ``HarnessKitTransform/TransformError/imageSaveFailed(_:_:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Writing the final composited image to disk failed.

## Overview

Thrown when the transform pipeline successfully composites a screenshot with its bezel but cannot write the resulting PNG to the output path. The first associated value is the destination `URL`; the second is the underlying `Error` from the image-writing API.

Common causes include insufficient disk space, missing write permissions, or the target volume being read-only.

## See Also

- ``outputDirectoryUnavailable(_:_:)``
