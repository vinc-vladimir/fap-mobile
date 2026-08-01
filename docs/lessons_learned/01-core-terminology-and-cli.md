# Lesson 1: Core Terminology & CLI Commands

## What We Did

We initialized the Flutter project (`flutter create`), configured dependencies in [`pubspec.yaml`](../../pubspec.yaml), installed them (`flutter pub get`), set up build_runner for code generation, and ran `flutter analyze` to verify everything compiles cleanly.

---

## Core Terminology

### Flutter & Dart

| Term | Definition |
|------|-----------|
| **Flutter** | An open-source UI framework by Google for building natively compiled apps for mobile (Android, iOS), web, and desktop from a single Dart codebase. Uses a widget-tree architecture where everything is a widget. |
| **Dart** | The programming language Flutter apps are written in. Developed by Google. Strongly typed, supports async/await, records, patterns, sealed classes. Compiles to native ARM code (mobile/desktop) or JavaScript (web). |
| **Widget** | The core building block of a Flutter UI. A widget describes a part of the UI (text, button, layout, padding, etc.). Widgets are nested to form a tree. Examples: `Text`, `Column`, `Scaffold`, `MaterialApp`. |
| **StatelessWidget** | A widget that doesn't have mutable state. Its appearance depends entirely on the configuration passed to it. Once built, it never changes. |
| **StatefulWidget** | A widget that has mutable state. Used when the UI needs to change dynamically (e.g., counter app, form inputs, animations). |
| **BuildContext** | An object that knows a widget's location in the widget tree. Used to access theme, routing, media queries, and other inherited widgets. Every `build` method receives one. |
| **[`pubspec.yaml`](../../pubspec.yaml)** | The project manifest file. Lists package name, dependencies, dev_dependencies, and Flutter configuration. Similar to `package.json` (Node.js) or `Cargo.toml` (Rust). |

### State Management & Code Gen

| Term | Definition |
|------|-----------|
| **Riverpod** | A compile-safe state management library for Flutter. Providers are declared as functions/variables and expose data to widgets. Widgets "watch" providers and rebuild automatically when data changes. Unlike older solutions, Riverpod doesn't need `BuildContext` to access state. |
| **Provider** | In Riverpod, a declarative way to expose a value or service to the widget tree. Examples: `Provider` (exposes a simple value), `FutureProvider` (async data), `StateNotifierProvider` (mutable state), `AsyncNotifierProvider` (modern replacement for StateNotifier). |
| **@riverpod annotation** | Part of `riverpod_generator`. You annotate a function with `@riverpod`, and the code generator creates the provider wiring automatically. Reduces boilerplate significantly. |
| **Freezed** | A code generator for immutable data classes. Gives you `copyWith` (create a modified copy), `==` equality (value comparison), `toString` (debug print), and JSON serialization with zero manual code. |
| **json_serializable** | A code generator that writes `fromJson()` / `toJson()` for your data classes. Paired with Freezed for automatic JSON parsing. |
| **build_runner** | The tool that runs code generators. Invoked with `dart run build_runner build`. It reads annotations (`@freezed`, `@riverpod`, `@JsonSerializable`) and generates `.g.dart` and `.freezed.dart` files. |

### Networking & Storage

| Term | Definition |
|------|-----------|
| **Dio** | An HTTP client library for Dart. Supports interceptors (middleware), request/response transformation, error handling, timeouts, and cancellation. Think: "Axios for JavaScript" or "OkHttp for Android." |
| **Interceptor** | Middleware that hooks into the HTTP request/response lifecycle. Common uses: attach JWT token to every request (AuthInterceptor), log requests (LogInterceptor), handle 401 errors globally (ErrorInterceptor). |
| **JWT** | JSON Web Token. A signed, encoded string containing user identity claims (user ID, email, role, expiry). Issued by the server on login. Sent as `Authorization: Bearer <token>` on every authenticated request. Stateless — the server validates the signature without storing session data. |
| **FlutterSecureStorage** | A plugin that stores small amounts of data encrypted on disk. On iOS it uses Keychain; on Android it uses AES-GCM encrypted SharedPreferences. Used to securely store the JWT token. |

### Routing

| Term | Definition |
|------|-----------|
| **go_router** | A declarative routing package maintained by the Flutter team. You define all routes in one place using a `GoRouter` object. Supports deep linking, redirect guards (for auth), and navigation state restoration. |
| **ShellRoute** | A go_router feature that wraps a group of child routes in a persistent shell widget. Used for bottom navigation bars — the shell (with the nav bar) stays visible while the child pages swap in/out. |
| **MaterialApp.router** | The alternative to standard `MaterialApp`. Instead of named routes, it takes a `GoRouter` instance. This enables declarative, type-safe routing. |

### Authentication & Security

| Term | Definition |
|------|-----------|
| **Passkey / WebAuthn** | A standard for passwordless authentication using public-key cryptography. The user's device generates a key pair — the private key stays on-device (secured by biometric/PIN), the public key is sent to the server. Login is a cryptographic signature challenge. |
| **OAuth2** | An authorization protocol that lets users log in via third-party providers (Google, GitHub). The app redirects to the provider's login page, the user authenticates, and the provider redirects back with an authorization code that the backend exchanges for tokens. |
| **flutter_appauth** | The Flutter package that handles the OAuth2 redirect flow. Opens a browser tab (Chrome Custom Tab on Android, ASWebAuthenticationSession on iOS) for the social login page, then intercepts the redirect back to the app. |

### Architecture Patterns

| Term | Definition |
|------|-----------|
| **Feature-first** | A project organization pattern where code is grouped by feature (auth, account, vehicles) rather than by type (screens, models, services). Each feature folder contains its own data layer (repositories, models) and presentation layer (providers, screens). |
| **Repository Pattern** | A layer that abstracts data access. The rest of the app calls repository methods (e.g., `authRepository.login()`), and the repository decides whether to call the API, read cache, etc. Makes it easy to change the data source without changing the UI. |
| **Provider (Dependency Injection)** | In Riverpod, providers also serve as dependency injection — you provide a service (like `Dio`) via a provider, and any feature can consume it. No need for a separate DI framework. |

---

## CLI Commands Reference

### Project Initialization

```bash
# Create a new Flutter project
flutter create --org com.vincsoftware --project-name fap_mobile fap-mobile
```

| Flag | Purpose |
|------|---------|
| `--org` | Reverse-domain package identifier (e.g., `com.vincsoftware` → `com.vincsoftware.fap_mobile`) |
| `--project-name` | Dart package name (lowercase, underscores allowed) |
| `fap-mobile` | Directory name for the project |

### Dependencies

```bash
# Install all dependencies listed in pubspec.yaml
flutter pub get

# Add a new dependency (updates pubspec.yaml + installs)
flutter pub add dio

# Add a dev dependency
flutter pub add --dev freezed

# Remove a dependency
flutter pub remove some_package

# Check for outdated packages
flutter pub outdated

# Upgrade to latest compatible versions
flutter pub upgrade
```

### Code Generation

```bash
# Run all code generators (freezed, json_serializable, riverpod_generator)
dart run build_runner build

# Run with auto-delete of conflicting outputs (recommended)
dart run build_runner build --delete-conflicting-outputs

# Run in "watch" mode — regenerates on every file change
dart run build_runner watch --delete-conflicting-outputs
```

### Analysis & Testing

```bash
# Check for errors and warnings
flutter analyze

# Run all tests
flutter test

# Run a specific test file
flutter test test/widget_test.dart

# Run tests and watch for changes
flutter test --watch
```

### Building

```bash
# Check available devices/emulators
flutter devices

# Run on a connected device or emulator
flutter run

# Build Android APK (debug)
flutter build apk --debug

# Build Android APK (release)
flutter build apk --release

# Build iOS (release, no code signing for testing)
flutter build ios --release --no-codesign

# Run on Chrome (web — fastest iteration for UI work)
flutter run -d chrome
```

### Common Fixes

```bash
# Clean build artifacts
flutter clean

# Reinstall dependencies after cleaning
flutter pub get

# Fully reset: clean → pub get → build_runner → analyze
flutter clean && flutter pub get && dart run build_runner build --delete-conflicting-outputs && flutter analyze
```

---

## Key Takeaway

The `flutter analyze` output showed **11 issues, all in `build/ios/SourcePackages/firebase_messaging/example/`** — inside a third-party package's example code, not our project. Our actual code ([`lib/main.dart`](../../lib/main.dart), [`test/widget_test.dart`](../../test/widget_test.dart)) had zero issues.

### Fix: Exclude `build/` from analysis

We added this to [`analysis_options.yaml`](../../analysis_options.yaml):

```yaml
analyzer:
  exclude:
    - "build/**"
```

This tells the Dart analyzer to skip the `build/` directory entirely. After the change: **No issues found.**

The `build/` directory is auto-generated (CocoaPods/SPM dependencies) and listed in [`.gitignore`](../../.gitignore). It would be regenerated on every `flutter pub get` or pod install — so attempting to delete the offending files is futile. The correct approach is always to exclude it from analysis.

The pattern `dart run build_runner build --delete-conflicting-outputs` will be run frequently — every time we add or modify a `@freezed` data class or `@riverpod` provider — since code generation is central to this project's architecture.
