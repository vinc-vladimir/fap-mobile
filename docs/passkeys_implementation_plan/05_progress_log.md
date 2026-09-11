# Implementation Log — Passkeys / WebAuthn

Chronological log of the WebAuthn feature work in `fap-mobile`. Newest entry on top.
Format: `## YYYY-MM-DD` → bullets (what was done, files, verification, blockers/notes).

---

## 2026-09-02 — Confirmed G1 blocker: native Android passkeys require a real RP domain

**Context**
- After the backend team fixed `/webauthn/register/options` (returns 200 + valid
  `PublicKeyCredentialCreationOptions`), the flow progressed to the Android Credential Manager
  sheet. With a test Google account + PIN set, the create still failed.

**Diagnostic finding (decisive)**
- Added `debugPrint('[passkey] ... platform error: $e')` in `PasskeyService.register/authenticate`.
- Exact platform error surfaced:
  `TYPE_CREATE_PUBLIC_KEY_CREDENTIAL_DOM_EXCEPTION/TYPE_DATA_ERROR — "RP ID cannot be validated."`
- Plugin README confirms: Android requires `https://<domain>/.well-known/assetlinks.json`
  (`delegate_permission/common.get_login_creds`, package + SHA-256 cert fingerprint), and the
  **RP ID must match that domain**. `localhost` cannot be validated by Google Play Services
  Credential Manager.

**Conclusion**
- `rp.id = "localhost"` (backend default) is **not usable** for native Android passkeys. This is
  audit **G1**, now confirmed and blocking end-to-end validation — the emulator-first assumption
  (decision D1) does not hold for the passkey ceremony. Emulator dev CAN still work IF a real
  public HTTPS domain is configured as RP (backend rpId + hosted assetlinks.json + app
  asset_statements); the emulator reaches the domain normally.

**Changes applied (mobile)**
- `android/app/src/main/AndroidManifest.xml`: removed the P1-10 placeholder `asset_statements`
  meta-data (it pointed to `fng.rs` while RP was `localhost`).
- Deleted `android/app/src/main/res/values/strings.xml` (placeholder only).
- `lib/features/auth/data/services/passkey_service.dart`: added diagnostic `debugPrint` in the
  register/authenticate error handlers (kept — useful for ongoing debugging).
- iOS `Runner.entitlements` placeholder untouched (dormant until G1).

**Artifacts prepared for G1 (from this device)**
- Android applicationId: `com.vincsoftware.fap_mobile`
- Debug signing SHA-256: `C5:C3:B1:4B:B7:74:E5:2D:21:D6:BE:CC:FE:B9:8F:2D:90:B9:76:37:AC:8C:D8:95:26:9C:04:66:05:4F:08:F1`

**Next**
- Decision needed: choose the RP domain (recommend apex `fng.rs`) and confirm the ability to host
  `assetlinks.json` on it. Then: backend rpId/origins change + app `asset_statements` + retest on
  emulator. See 01_decisions.md D6.

---

## 2026-08-31 — P1-10 Platform config + P1-11 Verify (Phase 1 complete)

**P1-10 — what was done**
- Android: `android/app/src/main/res/values/strings.xml` (new) — placeholder `asset_statements`
  string for the future RP domain (`fng.rs`); manifest `<meta-data android:name="asset_statements"
  android:resource="@string/asset_statements"/>`. Documented that `localhost` emulator dev does
  not need it.
- iOS: `ios/Runner/Runner.entitlements` (new) — `com.apple.developer.webcredentials` with
  placeholder `fng.rs`; wired `CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements` into the
  Runner Debug + Release build configs in `project.pbxproj`. Commented that iOS passkeys require
  a real domain + AASA (G1).

**P1-11 — verification**
- `dart run build_runner build` → ok (generated `.g.dart` files).
- `flutter analyze` → No issues found.
- `flutter test` → All tests passed.
- `flutter build apk --debug` → ✓ Built `app-debug.apk` (plugin built-in-Kotlin migration note is
  a warning only). Manual emulator ceremony script to be run by the user.

**Phase 1 complete.** Next: Phase 2 (backend-coordinated — G1 domain + G2/G3 list/delete).

---

## 2026-08-31 — P1-9 ARB strings (done)

**What was done**
- All 24 passkey/gate keys verified present in `app_en.arb`, `app_sr.arb`, and the regenerated
  `app_localizations.dart` (script check). Strings were added progressively during P1-6/P1-8.

**Verification**
- Script confirmed each key: en=1, sr=1, generated getter present.

**Next**
- P1-10 (platform config placeholders) → P1-11 (full verification + manual emulator test).

---

## 2026-08-31 — P1-8 Biometric re-open gate (done)

**What was done**
- `lib/features/auth/presentation/providers/auth_providers.dart` — `AuthState` now emits an
  `AuthStatus` enum (`loggedOut` / `biometricLocked` / `loggedIn`):
  - Cold-start restore: valid session + local passkey flag → `biometricLocked` (else `loggedIn`);
    same for the server-unreachable branch.
- `lib/features/auth/presentation/screens/biometric_gate_screen.dart` (new) — hero/glass design,
  auto-triggers the passkey ceremony on show, UNLOCK button (retry), "Use password" fallback
  (clears tokens → `/sign-in`), error SnackBars (cancel silent).
- `lib/core/router/app_router.dart` — added `/biometric-gate` route; redirect now switches on
  `AuthStatus`: `biometricLocked` → gate (unless already there); `loggedOut` → sign-in;
  `loggedIn` → shell (gate no longer reachable).
- Added gate ARB strings (en + sr) + `flutter gen-l10n`.

**Verification**
- `dart run build_runner build` (regen `.g.dart`), `flutter analyze` → No issues found.

**Next**
- P1-9 (ARB verification) + P1-10 (platform config placeholders) + P1-11 (verify + manual test).

---

## 2026-08-31 — P1-7 Sign-in biometric button (done)

**What was done**
- `lib/features/auth/presentation/screens/sign_in_screen.dart`:
  - Wired the existing "BIOMETRIC SIGN IN" button's empty `onPressed` to
    `PasskeyLoginController.loginWithPasskey()` (`_onBiometricSignIn`).
  - Button disabled while the ceremony is in progress; success → `context.go('/')`;
    failure → error SnackBar (cancel silent) via `passkeyErrorMessage`.

**Verification**
- `flutter analyze` → No issues found.

**Next**
- P1-8 (biometric re-open gate — `AuthState` enum + `BiometricGateScreen` + route).

---

## 2026-08-31 — P1-6 Settings screen — Add/Remove passkey (done)

**What was done**
- Added passkey ARB strings (en + sr) to `lib/l10n/app_en.arb` / `app_sr.arb` (settings rows,
  remove dialog, error messages, success messages) + `flutter gen-l10n`.
- `lib/features/auth/presentation/passkey_error_messages.dart` — shared `passkeyErrorMessage`
  (failure enum → localized string) and `isPasskeyCancellation`.
- `lib/features/settings/presentation/screens/settings_screen.dart`:
  - New "Passkey" row in the Security section (`Icons.fingerprint`).
  - Disabled state → tap runs `PasskeyRegistrationController.registerPasskey()` (spinner while
    registering; success/error SnackBars; cancel silent).
  - Enabled state → tap opens remove-confirm dialog → clears local flag only (D2), SnackBar.
- Noted: `.valueOrNull` → `.value` (Riverpod 3 API).

**Verification**
- `flutter analyze` → No issues found.

**Next**
- P1-7 (Sign-in biometric button wiring).

---

## 2026-08-31 — P1-5 Providers (done)

**What was done**
- `lib/features/auth/presentation/providers/passkey_providers.dart` (+ `.g.dart`):
  - `passkeyRepositoryProvider`, `passkeyServiceProvider`.
  - `passkeyEnabledProvider` (`keepAlive` Future<bool>) — reads/writes the local
    `FlutterSecureStorage` flag via `setEnabled(bool)` (D5).
  - `PasskeyRegistrationController.registerPasskey()` — options → platform register →
    `POST /webauthn/register` → flag on.
  - `PasskeyLoginController.loginWithPasskey()` — authenticate options → platform
    authenticate → `POST /v1/auth/login/webauthn` → persist JWT →
    `authStateProvider.setAuthenticated(true)` → invalidate `accountProvider`.
  - `_defaultDeviceLabel` ("Android"/"iPhone") used as the credential label.

**Verification**
- `dart run build_runner build` → generated `.g.dart`; `flutter analyze` → No issues found.

**Note**
- Logout does not clear the local `passkeyEnabled` flag yet; acceptable for emulator-first,
  revisit when server truth (G2) lands.

**Next**
- P1-6 (Settings screen — Add/Remove passkey rows) + required ARB strings.

---

## 2026-08-31 — P1-4 Platform service (done)

**What was done**
- `lib/features/auth/data/services/passkey_service.dart` — `PasskeyService` wrapping
  `PasskeyAuthenticator`:
  - `isAvailable()` (Android/iOS/web via `getAvailability()`).
  - `register(creationOptions)` → decoded `RegisterResponseType.toJson()` map.
  - `authenticate(requestOptions)` → decoded `AuthenticateResponseType.toJson()` map.
  - `PasskeyException` + `PasskeyFailure` enum mapping every plugin
    `AuthenticatorException` (cancel, no-credentials, Google-sign-in, domain-not-associated,
    no-create-option, device-unsupported, sync-unavailable, credential-exists, malformed
    challenge, timeout, unhandled).
- Verified plugin `toJson()` output against backend DTOs (03_api_contracts.md §6) — matches.

**Verification**
- `flutter analyze` → No issues found.

**Next**
- P1-5 (providers — register/login controllers + `passkeyEnabledProvider`).

---

## 2026-08-31 — P1-3 REST repository (done)

**What was done**
- `lib/features/auth/data/repositories/passkey_repository.dart` — `getRegisterOptions()`,
  `register({credential, label})`, `getAuthenticateOptions()`; `DioException` → `ApiException`
  (existing pattern). Login stays in `AuthRepository.loginWithPasskey`.

**Verification**
- `flutter analyze` → No issues found.

**Next**
- P1-4 (platform service — `PasskeyAuthenticator` wrapper).

---

## 2026-08-31 — P1-2 Models (done)

**What was done**
- `lib/features/auth/data/models/passkey_models.dart` — freezed models:
  `WebauthnRegisterRequest` (`{ publicKey: { credential: Map<String,dynamic>, label } }`),
  `WebauthnRegisterPublicKey`, `WebauthnRegisterResponse` (`{ success }`).
  Login assertion intentionally stays a raw `Map<String,dynamic>` (existing `loginWithPasskey`).

**Verification**
- `dart run build_runner build` → wrote 13 outputs (`.freezed.dart`, `.g.dart` generated).
- `flutter analyze` → No issues found.

**Next**
- P1-3 (REST repository).

---

## 2026-08-31 — P1-1 Core constants & storage (done)

**What was done**
- `lib/core/network/api_constants.dart` — added `passkeyEnabledKey` storage key and the
  `/webauthn/**` endpoint constants (`webauthnRegisterOptions`, `webauthnRegister`,
  `webauthnAuthenticateOptions`) under a new "WebAuthn endpoints" section. `webauthnLogin` was
  already present.
- `lib/core/storage/secure_storage.dart` — added `readPasskeyEnabled()` (bool, default false),
  `writePasskeyEnabled(bool)`, `clearPasskeyEnabled()`.

**Verification**
- `flutter analyze` → No issues found.
- User confirmed the app builds and runs successfully with these changes.

**Next**
- P1-2 (freezed `passkey_models.dart` + codegen).

---

## 2026-08-31 — Documentation scaffold (Phase 0)

**What was done**
- Created `docs/passkeys_implementation_plan/` with six documents:
  - `README.md` — index + status dashboard (phase table + Phase 1/2/3 checklists).
  - `01_decisions.md` — recorded decisions D1–D5 + reminders (token refresh, G1/G3) + open questions.
  - `02_backend_audit.md` — backend WebAuthn audit: confirmed behavior + gap table G1–G9 +
    recommended backend order + file references.
  - `03_api_contracts.md` — exact endpoint contracts for the 5 flows + `passkeys` plugin mapping +
    planned G2/G3 endpoints.
  - `04_mobile_implementation_plan.md` — detailed Phase 1 steps P1-1…P1-11 with files & "done when".
  - `05_progress_log.md` — this log.

**Context / inputs**
- Backend audit performed by the backend AI agent against `fap-service` (Spring Boot 4.1.0,
  Spring Security 7.1.0) — verified filter endpoint paths/JSON from jar bytecode.
- Key conclusions: 4 flows already contract-correct (no backend change needed for emulator dev);
  G1 (RP domain) is the real-device blocker; G2/G3 (list/delete passkeys) are new endpoints needed.

**Decisions recorded**
- D1 emulator-first · D2 remove = local flag only until G3 · D3 no real token refresh (reminder
  noted) · D4 full Phase 1 scope · D5 local flag = source of truth until G2.

**Verification**
- Folder created, files written. No code changed yet.

**Next**
- Begin **P1-1** (constants + secure storage) — see README checklist / 04 plan.
