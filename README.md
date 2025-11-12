# Color Puzzle Relax Game

A foundational Flutter project designed to grow into the relaxing color-based puzzle experience shown in the reference mockups. This initial iteration focuses on providing a clean architecture, dependency wiring, and state management so that future gameplay and visual layers can be added with confidence.

## Project Goals for This Iteration

- ✅ Establish a modular project structure separating core, domain, data, and presentation layers.
- ✅ Configure dependency injection with [`get_it`](https://pub.dev/packages/get_it) for easy composition.
- ✅ Provide domain models (`Level`, `GameBoard`, `GameSession`) and in-memory data sources.
- ✅ Implement state management with `provider`/`ChangeNotifier` that orchestrates level loading and session lifecycle.
- ✅ Define basic routing with `go_router` and placeholder screens ready to host future UI work.

## Requirements

- **Flutter SDK**: 3.16.0 or newer
- **Dart SDK**: 3.2.0 or newer

> The Flutter SDK path referenced in the request (`C:\\Users\\Nagre\\dev\\flutter`) can be exported via the `FLUTTER_HOME` environment variable or added to your system `PATH` to run the commands below.

## Getting Started

1. Install the Flutter and Dart versions listed above.
2. From the repository root run `flutter pub get` to install dependencies.
3. Run automated checks with `flutter test`.
4. Launch the skeletal application with `flutter run`.

The current UI is intentionally minimal: it lists seeded levels and lets you simulate starting/completing a level. The architecture is ready for integrating the full visual design and gameplay rules.

## Project Structure

```
lib/
  src/
    app.dart                # App root with providers and router
    core/
      constants/            # Shared values such as default board size
      di/                   # Service locator configuration
      router/               # go_router configuration
      theme/                # App-wide ThemeData definitions
    features/
      game/
        data/               # Data sources and repository implementations
        domain/             # Entities, repositories, and use cases
        presentation/       # Pages, widgets, and ChangeNotifiers
```

## Tests

Run the unit tests to validate the wiring:

```bash
flutter test
```

Additional tests can be added as more gameplay mechanics are implemented.
