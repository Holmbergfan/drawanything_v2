# Draw Anything - Development Guidelines

## Build & Run Commands
- Run app: `flutter run`
- Clean build: `flutter clean`
- Get dependencies: `flutter pub get`
- Run tests: `flutter test`
- Run single test: `flutter test test/widget_test.dart`
- Lint code: `flutter analyze`
- Format code: `dart format lib test`

## Code Style Guidelines
- Follow official Flutter style guide and linter rules from `flutter_lints`
- Use camelCase for variables/functions, PascalCase for classes/types
- Prefer late initialization over null assertions when type is guaranteed
- Error handling: Use try/catch with meaningful error messages, avoid print() in prod
- Immutable models with copyWith pattern for state updates
- Providers handle state management using ChangeNotifier pattern
- Organize imports: dart:core first, then Flutter, external packages, relative imports
- Document public APIs with /// comments for important classes and methods
- Wrap widgets in const constructor when possible for performance
- Keep files under 300 lines, prefer composition over inheritance
- Provider initialization in MultiProvider at app root

## Project Structure
- lib/models/ - Data structures
- lib/providers/ - State management
- lib/screens/ - Full page UI
- lib/widgets/ - Reusable components
- lib/utils/ - Helper functions