# Mobile Implementation Plan — fap-mobile

Detailed implementation plan for WebAuthn/passkeys in `fap-mobile`. Grounded in the backend audit
(02_backend_audit.md) and contracts (03_api_contracts.md). Status per step is tracked in
[README.md](./README.md) and logged in [05_progress_log.md](./05_progress_log.md).

> Emulator-first (D1): validated on Android emulator / iOS simulator with the existing
> `localhost` RP config. iOS passkeys require a real HTTPS domain (backend G1) — Phase 2.

## Phase 0 — Documentation & decisions (done)

- [x] Create `docs/passkeys_implementation_plan/` with index, decisions, audit, contracts, plan, log.
- [x] Record decisions D1–D5 (01_decisions.md).

## Phase 1 — Mobile implementation (no backend dependency)

### P1-1 · Core constants & storage

**Files**
- `lib/core/network/api_constants.dart`
- `lib/core/storage/secure_storage.dart`

**Work**
- Add endpoint constants:
  - `webauthnRegisterOptions = '/webauthn/register/options'`
  - `webauthnRegister = '/webauthn/register'`
  - `webauthnAuthenticateOptions = '/webauthn/authenticate/options'`
  - (already present: `webauthnLogin = '/v1/auth/login/webauthn'`)
- Add secure-storage key `passkeyEnabledKey`.
- Add `SecureStorage` methods: `readPasskeyEnabled()`, `writePasskeyEnabled(bool)`,
  `clearPasskeyEnabled()`.

**Done when:** constants referenced, storage methods compile, no analyzer errors.

### P1-2 · Models (freezed)

**File:** `lib/features/auth/data/models/passkey_models.dart` (+ `.freezed.dart`, `.g.dart`)

**Work** — freezed models mirroring the contracts:
- `WebauthnCreationOptions` / `WebauthnRequestOptions` — loose JSON passthrough (`Map<String, dynamic>`)
  is sufficient for the plugin; typed models only for what we must build/serialize ourselves:
  - `WebauthnRegisterRequest` — `{ publicKey: { credential: Map<String,dynamic>, label: String } }`
  - `WebauthnSuccessResponse` — `{ success: bool }`
- Keep login assertion as raw `Map<String, dynamic>` (already supported by `AuthRepository.loginWithPasskey`).

**Done when:** build_runner generates `.g.dart`/`.freezed.dart`; `flutter analyze` clean.

### P1-3 · REST repository

**File:** `lib/features/auth/data/repositories/passkey_repository.dart`

**Work**
- `Future<Map<String, dynamic>> getRegisterOptions()` → POST `webauthnRegisterOptions`, body `{}`.
- `Future<void> register({required Map<String,dynamic> credential, required String label})` →
  POST `webauthnRegister`, body `{ publicKey: { credential, label } }`.
- `Future<Map<String, dynamic>> getAuthenticateOptions()` → POST `webauthnAuthenticateOptions`, body `{}`.
- Login reuses `AuthRepository.loginWithPasskey(assertionMap)`.
- Wrap `DioException` → `ApiException` (existing pattern in `settings_repository.dart`).

**Done when:** methods compile, wired to `dioProvider`.

### P1-4 · Platform service

**File:** `lib/features/auth/data/services/passkey_service.dart`

**Work**
- `Future<PasskeyAvailability> isAvailable()` — wrap `PasskeyAuthenticator().getAvailability()`.
- `Future<Map<String, dynamic>> register(Map<String, dynamic> creationOptions)` —
  `RegisterRequestType.fromJsonString(jsonEncode(creationOptions))` →
  `authenticator.register(...)` → decode `RegisterResponseType.toJsonString()`.
- `Future<Map<String, dynamic>> authenticate(Map<String, dynamic> requestOptions)` —
  `AuthenticateRequestType.fromJsonString(jsonEncode(requestOptions))` →
  `authenticator.authenticate(...)` → decode `AuthenticateResponseType.toJsonString()`.
- Map typed plugin exceptions to a `PasskeyException` with user-facing message; allow cancel to
  surface distinctly (no error toast on user cancel).

**Done when:** analyzer clean; exception mapping unit-testable.

### P1-5 · Providers

**File:** `lib/features/auth/presentation/providers/passkey_providers.dart` (+ `.g.dart`)

**Work**
- `passkeyRepositoryProvider`, `passkeyServiceProvider`.
- `passkeyEnabledProvider` (`keepAlive`) — reads `SecureStorage.passkeyEnabled`; exposes setter
  that writes storage. **Local flag is source of truth until G2** (D5).
- `PasskeyRegistrationController` (`keepAlive`) — `registerPasskey()`:
  options → platform register → `POST /webauthn/register` → set flag true.
- `PasskeyLoginController` (`keepAlive`) — `loginWithPasskey()`:
  authenticate options → platform authenticate → `loginWithPasskey(assertion)` → persist JWT
  (same persistence path as `LoginController.login`) → `authStateProvider.setAuthenticated(true)`
  → invalidate `accountProvider`. Expose a flag for "app unlock" mode so the gate can re-auth
  without treating it as a fresh login.

**Done when:** generated code compiles; flows call through repository + service.

### P1-6 · Settings screen — Add / Remove passkey

**File:** `lib/features/settings/presentation/screens/settings_screen.dart`
(+ ARB strings from P1-9)

**Work**
- Add a "Passkey" row in the existing **Security** section `GlassCard`:
  - State from `passkeyEnabledProvider`: "Add Passkey" (disabled state) vs "Passkey enabled" + "Remove".
  - Tap → `PasskeyRegistrationController.registerPasskey()`; success → SnackBar + flag on;
    failure → error SnackBar (cancel = silent).
  - "Remove passkey" → confirm dialog → clears local flag only (D2). Include copy noting the
    server credential will be removed once backend G3 is available.

**Done when:** add/remove works on emulator; UI reflects flag; strings localized.

### P1-7 · Sign-in screen — wire biometric button

**File:** `lib/features/auth/presentation/screens/sign_in_screen.dart`

**Work**
- `_buildBiometricButton` already exists (`sign_in_screen.dart:219`, empty `onPressed`).
  Wire `onPressed` → `PasskeyLoginController.loginWithPasskey()`.
- On success → `context.go('/')`.
- On failure → error SnackBar (cancel = silent).
- Optionally hide/disable the button when `passkeys` unavailable or no flag set.

**Done when:** passkey sign-in works on emulator.

### P1-8 · Biometric re-open gate (app open → scan → home)

**Files**
- `lib/features/auth/presentation/providers/auth_providers.dart` (extend `AuthState`)
- `lib/features/auth/presentation/screens/biometric_gate_screen.dart` (new)
- `lib/core/router/app_router.dart`

**Work**
- `AuthState.build()` cold-start: after a stored token is validated (existing `GET /v1/account`
  check), if `passkeyEnabled == true` set `biometricLockRequired = true` instead of `true`.
  Track with a new `authState` value (e.g. an enum: `unknown/loggedOut/biometricLocked/loggedIn`)
  or a second provider consumed by the router.
- New `BiometricGateScreen`: brand/hero style consistent with Sign-in; triggers
  `PasskeyLoginController.loginWithPasskey()` in "unlock" mode on load; on success → clear lock →
  router shows `/`. On cancel → retry button + "Use password" fallback → clears tokens → `/sign-in`.
- Router: add `/biometric-gate` (public, only reachable when lock set). Guard: if
  `biometricLockRequired` → redirect any protected route to `/biometric-gate`.

**Done when:** kill & relaunch app on emulator with flag set → biometric gate → scan → home;
cancel path → sign-in.

### P1-9 · Localization (ARB)

**Files:** `lib/l10n/app_en.arb`, `lib/l10n/app_sr.arb`

**Work** — add keys (camelCase, both files, run `flutter pub get` to regen):
`settingsPasskey`, `passkeyEnabled`, `passkeyDisabled`, `passkeyAdd`, `passkeyRemove`,
`passkeyRemoveConfirmTitle`, `passkeyRemoveConfirmBody`, `passkeyRemoveLocalOnlyNote`,
`biometricGateTitle`, `biometricGateSubtitle`, `biometricSignInError`,
`passkeyUnavailable`, `passkeySignInUsePassword`, plus `@` metadata descriptions.

**Done when:** `AppLocalizations.of(context)!` resolves new keys; regen files committed.

### P1-10 · Platform config (emulator-first, placeholders)

**Files**
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Runner.entitlements` (or xcode project)

**Work**
- Android: add `android:assetStatements` (assetlinks) placeholder referencing the future RP
  domain; document that emulator dev with `localhost` needs the documented
  `adb reverse`/assetlink exception approach. No functional gate for emulator demo.
- iOS: add `com.apple.developer.webcredentials` entitlement with the future domain as a
  placeholder — **will not work until backend G1 sets a real domain**; clearly commented.

**Done when:** placeholders in place + documented; no build breakage.

### P1-11 · Verification

**Commands**
```bash
cd /Users/vvasic/Projects/FuelAutoPay/code/fap-mobile
dart run build_runner build --delete-conflicting-outputs
flutter analyze        # zero errors
flutter test           # all passing
```

**Manual emulator test script**
1. Sign in (email/password) → Settings → Add Passkey → biometric scan → "enabled".
2. Kill app → relaunch → biometric gate → scan → home.
3. Sign out → Sign-in → biometric button → scan → home.
4. Sign out → relaunch → gate → cancel → "Use password" → sign-in screen.
5. Register flow failure (server down) → error SnackBar; cancel → silent.

**Done when:** all commands pass and manual script passes on the Android emulator.

## Phase 2 — Backend-coordinated

- **P2-1 · G1 RP domain** — team picks domain; backend bean reads rpId/origins from config;
  mobile adds real `assetlinks.json` + AASA/webcredentials. Enables iOS + real-device passkeys.
- **P2-2 · G2/G3 list/delete** — backend ships `GET/DELETE /v1/account/webauthn-credentials`;
  switch `passkeyEnabledProvider` to server truth (D5); "Remove passkey" calls real DELETE (D2
  resolves). Update 03_api_contracts.md §7 with confirmed contracts.

## Phase 3 — Backend hardening (tracked, not mobile-blocking)

- G4 attachment mapping fix; G6 ProblemDetail on `/webauthn/**`; G9 tests + OpenAPI;
  G5 persistent options store; G7 real refresh token (D3 reminder).
- Mobile impact when they land: simplify `ApiException` parsing to a single shape (G6);
  store/use real refresh token (G7).

## Emulator caveats

- **Android emulator:** passkey flows with rpId `localhost` generally work for demos
  (Google Play Services on emulator). See P1-10 assetlink note.
- **iOS simulator/device:** passkeys require a real HTTPS domain + AASA (G1). The iOS UI will
  hide/disable the passkey button until then.
- Backend `refresh_token` is a placeholder — re-open re-mints a fresh JWT via passkey auth (D3).
