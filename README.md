# Paper Boat Pulse

Responsive Flutter mini-project for the Paper Boat Tech engineering evaluation.

## Included deliverables

- Responsive mobile, tablet, and desktop layouts using `LayoutBuilder` and `MediaQuery`.   //162,163
- Orientation-safe scrolling UI with adaptive grid/card sizing.  183,844,888
- `Hero` brand transition and an interactive `AnimatedContainer` welcome card.  //708,794
- Custom typography using Google Fonts (`Manrope`). //30,43,730,730,721
- Bundled SVG brand asset declared in `pubspec.yaml`.  //702,746,809
- Structured lifecycle and interaction logging using `logger`; no `print` calls.   //82,91,101,134
- `fl_chart` weekly momentum visualization.   //1.879,880
- App title (`Paper Boat Pulse`) and `flutter_launcher_icons` configuration for native branding.  //24

## Requirements

- Flutter 3.19+ and Dart 3.3+
- Android Studio or Xcode for native builds

## Setup and run

```bash
# Generate Android and iOS runners for this existing Flutter project.
flutter create --platforms=android,ios .
flutter pub get
dart run flutter_launcher_icons
flutter analyze
flutter test
flutter run
```

The generated native runners use the `paper_boat_pulse` project name (shown as
`Paper Boat Pulse` on device). Run `dart run flutter_launcher_icons` after
changing `assets/brand_mark.svg` to regenerate the launcher assets.

Use Flutter's device/orientation controls to verify portrait and landscape behavior:

```bash
flutter devices
flutter run -d <device-id>
```

## Build

```bash
flutter build apk --release
# or
flutter build ios --release
```
## Command to run this project
& "D:\flutter\bin\flutter.bat" run -d edge
