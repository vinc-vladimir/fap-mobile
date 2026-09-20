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

After signing up, the backend emails a one-time confirmation link. Two URI forms
are supported, and both are routed by `lib/core/deep_links/deep_link_handler.dart`
to the in-app route `/confirm-registration/<token>`:

| URI | Purpose |
|---|---|
| `fap://registration-confirm?token=<TOKEN>` | Manual `adb` testing / back-compat (custom scheme) |
| `https://dev.fap.rs/registration-confirm?token=<TOKEN>` | Tappable link in the confirmation email (Gmail does not open custom schemes) |

Trigger the same deep link directly from the command line to confirm a
registration without opening the email (replace the token):

```bash
# Custom scheme (manual adb testing)
adb shell am start -a android.intent.action.VIEW -d "fap://registration-confirm?token=10e05099-900e-4639-9532-46e82996c781"

# HTTPS App Link (the form sent in the confirmation email)
adb shell am start -a android.intent.action.VIEW -d "https://dev.fap.rs/registration-confirm?token=10e05099-900e-4639-9532-46e82996c781"
```

Notes:

- The `fap://` scheme is kept for `adb`; Gmail does not open custom schemes, so the
  email uses the HTTPS App Link instead.
- HTTPS App Links require the `dev.fap.rs` association (`static/.well-known/assetlinks.json`
  in `fap-infra`) and are **Android-only** for now — iOS Universal Links are not configured.
- Watch the app log for the `[DeepLinkHandler]` line to confirm the URI was parsed and routed.

## Resetting your password (Forgot Password) locally

After requesting a reset, the backend emails a one-time link. As with registration,
two URI forms are supported and both are routed by
`lib/core/deep_links/deep_link_handler.dart` to the in-app route `/reset-password/<token>`:

| URI | Purpose |
|---|---|
| `fap://set-new-password?token=<TOKEN>` (`fap://reset-password?token=<TOKEN>` alias) | Manual `adb` testing / back-compat (custom scheme) |
| `https://dev.fap.rs/set-new-password?token=<TOKEN>` | Tappable link in the reset email (Gmail does not open custom schemes) |

Trigger the same deep link directly from the command line to reach the set-new-password
screen without opening the email (replace the token):

```bash
# Custom scheme (manual adb testing)
adb shell am start -a android.intent.action.VIEW -d "fap://set-new-password?token=10e05099-900e-4639-9532-46e82996c781"

# HTTPS App Link (the form sent in the reset email)
adb shell am start -a android.intent.action.VIEW -d "https://dev.fap.rs/set-new-password?token=10e05099-900e-4639-9532-46e82996c781"
```

Notes:

- The backend emits `set-new-password`; `reset-password` is accepted as an alias for manual testing.
- Both email flows share the same Android App Link / `dev.fap.rs` association; iOS Universal
  Links are not configured yet.
- Watch the app log for the `[DeepLinkHandler]` line to confirm the URI was parsed and routed.

## Organization (Phase 1)

The Account tab → **Organization** opens the organization area. A user belongs to **at most
one** organization; the account that creates one becomes its `ORG_OWNER`, invited users join
as `ORG_MEMBER`.

| Route | Screen |
|---|---|
| `/account/organization` | Empty state (create CTA) or the profile; owner sees **Edit** + **Deactivate**, a member is read-only |
| `/account/organization/create` | Create the organization profile |
| `/account/organization/edit` | Edit the organization profile (owner only) |

Endpoints (source of truth: `fap-service/doc/openapi/organization-api.yaml`):

| Method | Path | Notes |
|---|---|---|
| GET | `/v1/organizations/me` | Membership `{ organizationId, role }`; both `null` when the user has none |
| POST | `/v1/organizations` | Create; caller becomes `ORG_OWNER` (`409` if already in one) |
| GET | `/v1/organizations/{id}` | Organization profile |
| PUT | `/v1/organizations/{id}` | Update writable fields (owner) |
| POST | `/v1/organizations/{id}/deactivate` | Soft delete (owner) |

Members, fleet vehicles, fleet payment cards and invitations are later phases. Full plan and
progress: [`docs/organization_implementation_plan_with_progress_status.md`](docs/organization_implementation_plan_with_progress_status.md).

## Testing

```bash
flutter test                                          # all tests
flutter test test/organization_repository_test.dart   # a single file
```

> **macOS prerequisite:** if `flutter test` fails while *"Building assets for package:
> objective_c"* with *"You have not agreed to the Xcode license agreements."*, accept the
> license once with `sudo xcodebuild -license accept` (or `sudo xcodebuild -runFirstLaunch`).
> The passkeys/`objective_c` native-assets build invokes `xcrun`/`clang`, which are gated
> behind the Xcode license.

## Emulator internal storage full

Symptom: `flutter run` fails during install with:

```
adb: failed to install .../app-debug.apk:
  Requested internal only, but not enough space
```

The emulator's `/data` partition is full. Stop the emulator and wipe its writable
storage with the helper script:

```bash
tool/clean_emulator.sh
```

The script:

1. Stops the running `Pixel_9` emulator (if any).
2. Deletes the writable data overlays and fast-boot snapshot under
   `~/.android/avd/Pixel_9.avd/` (`userdata-qemu.img*`, `cache.img.qcow2`,
   `encryptionkey.img.qcow2`, `snapshots/default_boot/`).
3. Leaves the base images intact, so the emulator rebuilds a fresh disk on next boot.

Then start the emulator again from IntelliJ and verify the freed space with
`adb shell df -h /data`.

> The script does **not** restart the emulator, and it wipes **all** emulator state
> (installed apps, accounts, settings). It is safe to re-run — it is a no-op when
> the emulator is already stopped and storage is clean.

## Useful terminal commands

### Device & emulator

| Command | What it does |
|---|---|
| `adb devices` | List connected devices/emulators. |
| `adb shell df -h /data` | Show used/free space on the emulator's internal storage. |
| `adb shell getprop sys.boot_completed` | Prints `1` once the emulator has fully booted. |
| `adb -s emulator-5554 emu avd name` | Show which AVD a running emulator belongs to. |
| `adb -s emulator-5554 emu kill` | Stop the emulator. |
| `flutter emulators` | List available emulators. |
| `flutter emulators --launch Pixel_9` | Launch an emulator by id. |
| `tool/clean_emulator.sh` | Stop the Pixel_9 emulator and wipe its internal storage (see above). |

### App on device

| Command | What it does |
|---|---|
| `adb shell pm clear com.vincsoftware.fap_mobile` | Clear the app's data and cache. |
| `adb uninstall com.vincsoftware.fap_mobile` | Uninstall the app. |
| `adb logcat -s flutter` | Stream Flutter app logs. |
| `adb shell am start -a android.intent.action.VIEW -d "fap://registration-confirm?token=<TOKEN>"` | Fire the registration-confirm deep link manually. |

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
- **`adb: ... not enough space` when installing on the emulator** → `tool/clean_emulator.sh`, then start the emulator again
