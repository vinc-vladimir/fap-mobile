# Backend Integration, Auth & JWT — Lessons Learned

## Overview

This phase integrated the Flutter app with the Spring Boot `fap-service` backend
for the first time: a **core network layer** (Dio client + JWT interceptors + secure
storage), the **auth REST flow** (Sign Up → email confirmation → Sign In → Sign Out),
and **deep linking** so the confirmation email opens the app directly via a custom
`fap://` URL scheme. Development of the email-confirmation flow was done **without
logging into a real mail client on the emulator** — the token is copied from the
backend log and injected with `adb`/`simctl`.

Real API calls now drive the auth screens: Sign Up posts to `/v1/auth/registration`,
the deep link confirms via `/v1/auth/confirm/registration`, Sign In posts to
`/v1/auth/login` and stores the returned JWT, and Sign Out calls `/v1/auth/logout`
then clears local tokens.

---

## Files Created / Modified

| File | Purpose |
|---|---|
| `fap-service/src/main/resources/application.yml` | `reg-confirm-url` default → `fap://registration-confirm?token=` |
| `fap-service/.env` | `REG_CONFIRM_URL=fap://registration-confirm?token=` (dev override) |
| [`lib/core/network/api_client.dart`](../../lib/core/network/api_client.dart) | Dio instance (`dioProvider`) + `managementDioProvider` for actuator probes |
| [`lib/core/network/api_interceptors.dart`](../../lib/core/network/api_interceptors.dart) | `AuthInterceptor` — attaches `Authorization: Bearer` from storage, clears on 401 |
| [`lib/core/network/api_constants.dart`](../../lib/core/network/api_constants.dart) | Base URLs, endpoint paths, secure-storage keys |
| [`lib/core/network/api_exceptions.dart`](../../lib/core/network/api_exceptions.dart) | `ApiException.fromDio` — maps backend error JSON → user-facing message |
| [`lib/core/storage/secure_storage.dart`](../../lib/core/storage/secure_storage.dart) | `FlutterSecureStorage` wrapper (`SecureStorage` + `secureStorageProvider`) |
| [`lib/core/deep_links/deep_link_handler.dart`](../../lib/core/deep_links/deep_link_handler.dart) | Parses `fap://registration-confirm?token=…` → pushes `ConfirmRegistrationScreen`; holds app `navigatorKey` |
| [`lib/main.dart`](../../lib/main.dart) | `MaterialApp.navigatorKey`, cold-start `getInitialLink()` + warm `uriLinkStream` subscription |
| [`lib/features/auth/data/repositories/auth_repository.dart`](../../lib/features/auth/data/repositories/auth_repository.dart) | REST calls: register, confirmRegistration, login, logout, token exchange, passkey, password reset |
| [`lib/features/auth/data/models/auth_models.dart`](../../lib/features/auth/data/models/auth_models.dart) | Freezed DTOs: `LoginRequest`, `AuthResponse`, `EmailTokenRequest`, etc. |
| [`lib/features/auth/presentation/providers/auth_providers.dart`](../../lib/features/auth/presentation/providers/auth_providers.dart) | `authRepositoryProvider`, `LoginController` (login/logout, `keepAlive`), `RegistrationController`, `confirmRegistrationProvider` |
| [`lib/features/auth/presentation/screens/sign_in_screen.dart`](../../lib/features/auth/presentation/screens/sign_in_screen.dart) | Wired to `LoginController` — loading spinner, error snackbar, navigate on success |
| [`lib/features/auth/presentation/screens/sign_up_screen.dart`](../../lib/features/auth/presentation/screens/sign_up_screen.dart) | Submits to `RegistrationController`, then `EmailSentScreen` |
| [`lib/features/auth/presentation/screens/confirm_registration_screen.dart`](../../lib/features/auth/presentation/screens/confirm_registration_screen.dart) | Loading → success ("Account Activated") / error ("Confirmation Failed") |
| [`lib/features/account/presentation/screens/account_screen.dart`](../../lib/features/account/presentation/screens/account_screen.dart) | Sign Out tile → `LoginController.logout()` → `SignInScreen` |
| [`lib/l10n/app_en.arb`](../../lib/l10n/app_en.arb), [`app_sr.arb`](../../lib/l10n/app_sr.arb) | New confirm/login strings; updated `registrationSuccessDescription` |
| [`pubspec.yaml`](../../pubspec.yaml) | Added `app_links: ^6.4.1` |
| `android/app/src/main/AndroidManifest.xml` | `fap://` intent-filter (`autoVerify`) on `MainActivity` |
| `android/app/src/debug/AndroidManifest.xml` | `usesCleartextTraffic="true"` so dev builds can call `http://10.0.2.2:8080` |
| `ios/Runner/Info.plist` | `CFBundleURLTypes` registering the `fap` scheme |

---

## Key Decisions

### 1. Confirmation email links use a custom `fap://` deep link
The backend builds the confirmation link from `reg-confirm-url` (env-configurable),
now `fap://registration-confirm?token=…`. Tapping it on the phone opens the app
instead of a dead web page. The **token is the payload**, not the mail client — so
testing never requires logging into email on the emulator.

### 2. Dev flow: copy the token from the backend log, inject via adb/simctl
The backend logs the full confirmation link. To exercise the real deep-link path:
`adb shell am start -a android.intent.action.VIEW -d "fap://registration-confirm?token=<TOKEN>"`
(Android) / `xcrun simctl openurl booted "fap://…"` (iOS). No mail app needed on the
emulator; the email is read once on the host machine.

### 3. No auto-login after email confirmation
`POST /v1/auth/confirm/registration` consumes the single-use OTT and sets
`emailVerified`, but does **not** return a JWT (and `token/exchange` requires an
already-verified user). So after confirming, the user signs in manually — matching
the old Angular flow. Auto-login would need a backend change.

### 4. JWT storage + interceptor, not manual header handling
On login the `access_token` (and `refresh_token` when real) is written to
`FlutterSecureStorage`. `AuthInterceptor` reads it on every request; on a 401 it
clears tokens. Screens never touch headers directly.

### 5. `LoginController` is `keepAlive`
Session/auth state must outlive any single screen. Default auto-dispose providers
were being disposed mid-async (the "Cannot use Ref after disposed" crash) — see
Lessons Learned #4.

### 6. Sign Out is best-effort against the server, authoritative locally
`logout()` calls `POST /v1/auth/logout` but ignores failures — the local session is
always cleared and the user always returns to Sign In. The server call is a nicety;
a dead network must not lock the user in.

### 7. Cleartext HTTP is allowed in debug builds only
Android 9+ blocks `http://` by default. `android/app/src/debug/AndroidManifest.xml`
sets `android:usesCleartextTraffic="true"` so the emulator can reach
`http://10.0.2.2:8080`. Release builds keep the secure-by-default policy.

---

## Lessons Learned

### 1. The custom-scheme "route" is the URI host, not the path
`fap://registration-confirm?token=…` parses as `scheme=fap`, `host=registration-confirm`,
`path=""`. `DeepLinkHandler` therefore reads `uri.path.isEmpty ? uri.host : uri.path`.
If we later switch to https links, the route moves to `uri.path` — handle both.

### 2. Platform deep-link config is mandatory and requires a fresh install
`app_links` on its own does nothing — you must also register the scheme:
Android `<intent-filter android:autoVerify>` + iOS `CFBundleURLTypes`, then **rebuild
and reinstall** the app. Manifest-only changes are not picked up by hot reload. The
`adb` warning "Activity not started, intent has been delivered to currently running
top-most instance" is expected and fine — the intent is delivered via the stream.

### 3. Riverpod code-gen: family functions take plain `Ref`
For `@riverpod Future<void> confirmRegistration(…, {required String token})`, the
generator passes a plain `Ref` — typing the param as the "obvious" generated name
(`ConfirmRegistrationRef`) is an `undefined_class` error. Use `Ref`.

### 4. Auto-dispose providers get disposed during async gaps — use `keepAlive`
`LoginController.logout()` does `await` calls then writes `state`. Because nothing
`watch`es the provider (Account Screen only `ref.read`s), the auto-dispose provider
was disposed between the awaits → `Cannot use the Ref of loginControllerProvider after
it has been disposed`. Fix: `@Riverpod(keepAlive: true)`. **Rule: any provider that
represents global/session state, or mutates state after async work while not
persistently watched, should be `keepAlive`.**

### 5. Stale analyzer errors can come from mid-edit states
After a multi-step refactor, the analyzer can report errors that reflect an
intermediate state (e.g. "Too many positional arguments: 2 expected, but 4 found"
when call sites were updated before the callee signature). Always trust a fresh
`flutter analyze` over the last reported errors.

### 6. `AsyncValue.when` callbacks have fixed signatures
`when(error: (Object error, StackTrace stackTrace) {…})` gives you exactly two args.
Extract helper builders that receive `context`/`ref`/`theme`/`l10n` explicitly rather
than trying to reach them through the callback.

### 7. The backend's `refresh_token` is currently `"placeholder"`
`/v1/auth/login` returns `access_token` (RSA-256, 15 min TTL) and a literal
`"placeholder"` refresh token. `AuthRepository` stores it if non-empty, but real
token refresh isn't possible yet — a follow-up on the backend.

### 8. `ApiException.fromDio` gives user-facing messages
Backend error bodies (`detail`/`title`/`message`, or HTTP status text) are extracted
and surfaced via `SnackBar` — so bad credentials and expired confirm tokens show a
meaningful message instead of a raw Dio error.

### 9. Dio `LogInterceptor` is the debug win
With `LogInterceptor(requestBody: true, responseBody: true)`, the console shows the
full request/response — the fastest way to confirm headers (e.g. `Authorization:
Bearer …`) are attached and to inspect token payloads.

### 10. `withValues(alpha:)` for opacity, never `withOpacity`
Consistent with Flutter 3.44+; `withOpacity` is deprecated.

### 11. Emulator base URL differs by platform
`ApiConstants.localBaseUrl` uses `10.0.2.2:8080` on Android emulators and
`localhost:8080` on iOS simulators (which share the host network). Physical devices
need the host LAN IP via `--dart-define`.

---

## Verification

```bash
flutter analyze                     # No issues found
flutter test                        # All passing
dart run build_runner build         # After any provider/ARB change
adb shell am start -a android.intent.action.VIEW \
  -d "fap://registration-confirm?token=<TOKEN>"   # Manual deep-link test
```

Confirmed end-to-end: Sign Up → email (SES) → copy deep link from backend log →
`adb` inject → `ConfirmRegistrationScreen` ("Account Activated") → Sign In
(`POST /v1/auth/login`, 200, JWT returned) → Home → Sign Out.

---

## Follow-ups

1. ~~**Migrate to go_router**~~ — done (see
   [`05-email-confirm-deeplink-gorouter.md`](05-email-confirm-deeplink-gorouter.md)
   for the go_router `StatefulShellRoute` redirect pitfalls encountered).
2. **Real refresh-token flow** — backend returns `"placeholder"`; implement refresh
   + `AuthInterceptor` auto-retry on 401.
3. **Auto-login after email confirmation** — needs a backend change (confirm
   endpoint issuing a JWT), then the confirm screen can go straight to Home.
4. **Forgot-password deep link** (`fap://reset-password`) — reuse the same
   `app_links` plumbing; backend `FORGOTTEN_PWD_URL` is already configurable.
5. **Account screen** — "Change Password" tile is still a stub.
6. **Promote remaining raw hex colors** in `home_screen.dart`/`account_screen.dart`
   to named constants (AGENTS token rule).
