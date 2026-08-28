# Paper Boat Pulse

Responsive Flutter mini-project for the Paper Boat Tech engineering evaluation.

## Included deliverables

- Responsive mobile, tablet, and desktop layouts using `LayoutBuilder` and `MediaQuery`.
- Orientation-safe scrolling UI with adaptive grid/card sizing.
- `Hero` brand transition and an interactive `AnimatedContainer` welcome card.
- Custom typography using Google Fonts (`Manrope`).
- Bundled SVG brand asset declared in `pubspec.yaml`.
- Structured lifecycle and interaction logging using `logger`; no `print` calls.
- `fl_chart` weekly momentum visualization.
- App title (`Paper Boat Pulse`) and `flutter_launcher_icons` configuration for native branding.

## Requirements

- Flutter 3.19+ and Dart 3.3+
- Android Studio or Xcode for native builds

## Setup and run

```bash
flutter create .
flutter pub get
dart run flutter_launcher_icons
flutter analyze
flutter test
flutter run
```

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

## GitHub submission

Create a new public repository named `paper-boat-pulse`, then push this project:

```bash
git init
git add .
git commit -m "Build responsive Paper Boat Pulse Flutter app"
git branch -M main
git remote add origin https://github.com/<your-username>/paper-boat-pulse.git
git push -u origin main
```
