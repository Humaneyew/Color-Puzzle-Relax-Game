# Color Puzzle Relax Game

Color Puzzle Relax Game is a Flutter project that provides a calm, color-based puzzle experience. This repository contains the source code for the mobile application along with the assets required to build and run the game.

## Toolchain Requirements

- **Flutter**: 3.16 or newer
- **Dart**: 3.2 or newer

Make sure the Flutter SDK installed on your system meets or exceeds the versions above before running `flutter run` or other build commands.

### Android configuration note

The Gradle setup in [`android/settings.gradle`](android/settings.gradle) expects either:

- a `local.properties` file that defines `flutter.sdk`, or
- the `FLUTTER_HOME` environment variable pointing to the Flutter SDK location.

If neither is provided the build will fail with an error indicating the Flutter SDK cannot be found. Configure one of these options before building the Android app.

## Getting Started

1. Install the required Flutter and Dart versions listed above.
2. Run `flutter pub get` to fetch dependencies.
3. Launch the app with `flutter run` targeting your desired device or emulator.

For additional Flutter development guidance, refer to the [official Flutter documentation](https://docs.flutter.dev/).
