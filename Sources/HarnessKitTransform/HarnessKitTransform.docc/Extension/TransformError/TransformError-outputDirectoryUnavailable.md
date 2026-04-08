# ``HarnessKitTransform/TransformError/outputDirectoryUnavailable(_:_:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

The output directory could not be created.

## Overview

Thrown when the transform pipeline attempts to create the destination directory for composited images and the file-system operation fails. The first associated value is the target `URL`; the second is the underlying `Error` from `FileManager`.

Check that the parent directory exists and that the process has write permissions at the specified path.

## See Also

- ``imageSaveFailed(_:_:)``
