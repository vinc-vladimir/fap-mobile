# fap_mobile

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Confirming registration (Sign Up) locally

After signing up, the backend emails a one-time confirmation link. When
developing locally you can trigger the same deep link directly from the
command line to confirm a registration without opening the email:

```bash
adb shell am start -a android.intent.action.VIEW -d "fap://registration-confirm?token=10e05099-900e-4639-9532-46e82996c781"
```

## Common Flutter commands

| Command | When to use it |
|---|---|
| `flutter analyze` | Check for static analysis errors/warnings. Run after any code change, before committing. |
| `flutter pub get` | Install / sync dependencies declared in `pubspec.yaml`. Run after adding, removing, or changing a dependency's version, and after editing `lib/l10n/*.arb` files (triggers code generation for localizations). |
| `flutter clean` | Delete generated and build artifacts. Run when you suspect stale build output is causing issues (e.g. after a package upgrade or build errors that won't go away). |
| `flutter pub upgrade` | Update all dependencies to the latest compatible versions. Run when you want newer versions of packages. |
| `flutter pub outdated` | Show which dependencies have newer versions available. Run to review what could be upgraded. |
| `dart run build_runner build --delete-conflicting-outputs` | Regenerate code (freezed, json_serializable, riverpod_generator). Run after editing files that use these generators. |

### Workflow examples

- **Just changed a color or UI code** → `flutter analyze`
- **Added a new dependency to `pubspec.yaml`** → `flutter pub get`
- **Changed models / providers that use code generation** → `dart run build_runner build --delete-conflicting-outputs`
- **After a dependency upgrade or weird build errors** → `flutter clean` then `flutter pub get`
