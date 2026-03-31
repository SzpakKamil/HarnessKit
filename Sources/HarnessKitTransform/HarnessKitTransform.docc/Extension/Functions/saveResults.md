# ``HarnessKitTransform/saveResults(image:name:to:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticArticleSubheading(disabled)
}

Saves an image as a PNG file inside the given directory.

## Overview

`saveResults` converts `image` to PNG data and writes it to `directory/name.png`. The `.png` extension is appended automatically if not present in `name`. The directory is created with intermediate directories if it does not exist.

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `image` | `NSImage` | The image to write. |
| `name` | `String` | Output filename without extension (`.png` is appended). |
| `directory` | `URL` | Destination directory. Created if it does not exist. |

## Throws

- `TransformError.outputDirectoryUnavailable` if the directory cannot be created.
- `TransformError.imageSaveFailed` if PNG conversion or file writing fails.

## Example

```swift
let outputDir = URL(fileURLWithPath: "/Users/me/Desktop/Screenshots")
try saveResults(image: composedImage, name: "home-iOS", to: outputDir)
// writes: /Users/me/Desktop/Screenshots/home-iOS.png
```
