# SlideshowWallpaper

A small macOS app that displays a slideshow/video as the wallpaper using SwiftUI and AVKit components.

This repository contains the app source code and assets for a simple slideshow wallpaper application.

## Features

- Play videos or image slideshows inside a SwiftUI window
- Keeps the system awake while the slideshow is running (see `SleepPreventer.swift`)
- Uses an AV player-backed view for media playback (`AVPlayerView.swift`)

## Requirements

- macOS with Xcode installed
- Swift 5 (the project file lists `SWIFT_VERSION = 5.0`)
- The project file currently lists `MACOSX_DEPLOYMENT_TARGET = 26.1` in `SlideshowWallpaper.xcodeproj/project.pbxproj`; confirm or change this in Xcode as needed for your target macOS version.

## Getting Started

1. Open the project in Xcode:

```bash
open SlideshowWallpaper.xcodeproj
```

2. Select the `SlideshowWallpaper` scheme and run the app (⌘R) or build an archive as needed.

Alternatively, build from the command line:

```bash
xcodebuild -project SlideshowWallpaper.xcodeproj -scheme SlideshowWallpaper -configuration Debug
```

## Configuration

- The repository includes a `config.json` file in the project root — edit this file to change slideshow settings (image/video sources, durations, order, etc.).
- Bridge headers and Obj-C interop are configured in `SlideshowWallpaper-Bridging-Header.h` if you need to add Objective-C components.

## Key Files

- `SlideshowApp.swift` — app entry point
- `ContentView.swift` — SwiftUI main view
- `SlideshowViewModel.swift` — view model that controls slideshow state and logic
- `AVPlayerView.swift` — AVKit-backed view used for video playback
- `SleepPreventer.swift` — prevents the system from sleeping while slideshow is active
- `SlideshowWallpaper-Bridging-Header.h` — Objective-C bridging header (if needed)
- `Assets.xcassets` — app icons and color assets

## Development Notes

- The project is structured as a typical SwiftUI macOS app. Implement new features by updating the view model and views.
- If you change deployment targets or Swift toolchain settings, update them in Xcode or in `project.pbxproj`.

## Contributing

If you'd like to contribute, please open an issue or send a pull request with a clear description of the change.

## License

No license file is included in this repository. Add a `LICENSE` file to specify the terms under which your code can be used.

## Author

Project owner: `koko-lockerns` (bundle id: `koko-lockerns.SlideshowWallpaper`)

---

If you'd like, I can:

- Run a quick search through the source files to extract more specific usage examples.
- Add screenshots or a sample `config.json` snippet to the README.
- Add a `LICENSE` (e.g., MIT) or set up a CI workflow to run builds.
