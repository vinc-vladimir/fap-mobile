# Forgot Password Email Deep Link + Reset Screen — Lessons Learned

## Overview

This phase completed the **forgot-password / password-reset flow** end-to-end and made the
reset email link open the app, reusing the HTTPS App Link pattern established for
registration confirmation in [`06-app-links-registration-confirm.md`](06-app-links-registration-confirm.md).

End-to-end:

1. **Forgot Password** screen → `POST /v1/auth/forgotten/password/email` (via
   `ForgottenPasswordEmailController`) → navigates to the "Check Your Email" screen.
2. `fap-service` emails an HTTPS App Link:
   `https://dev.fap.rs/set-new-password?token=…` (env `FORGOTTEN_PWD_URL`).
3. Tapping the link in Gmail opens the app; `app_links` delivers it to `FapApp._handleDeepLink`,
   `DeepLinkHandler.routeForUri` maps it to `/reset-password/<token>`, and the
   `ResetPasswordScreen` is **presented directly on the navigator**.
4. User submits a new password → `POST /v1/auth/forgotten/password` (via
   `ResetPasswordController`) → success content → back to Sign In.

Both `fap://set-new-password?token=…` and the `reset-password` alias remain available for
manual `adb` testing.

---

## Files Created / Modified

| File | Purpose |
|---|---|
| [`lib/features/auth/presentation/screens/reset_password_screen.dart`](../../lib/features/auth/presentation/screens/reset_password_screen.dart) | **New.** Token-driven set-new-password form (password + confirm, live requirement checklist), invalid-link and success states |
| [`lib/features/auth/presentation/screens/forgot_password_screen.dart`](../../lib/features/auth/presentation/screens/forgot_password_screen.dart) | Now calls `ForgottenPasswordEmailController.send(...)`, shows a spinner + error SnackBar, then `context.go('/email-sent')` |
| [`lib/features/auth/presentation/providers/auth_providers.dart`](../../lib/features/auth/presentation/providers/auth_providers.dart) | Added `ForgottenPasswordEmailController` (`send`) and `ResetPasswordController` (`reset`) |
| [`lib/features/auth/data/repositories/auth_repository.dart`](../../lib/features/auth/data/repositories/auth_repository.dart) | `sendForgottenPasswordEmail` and `resetPassword` REST calls |
| [`lib/core/deep_links/deep_link_handler.dart`](../../lib/core/deep_links/deep_link_handler.dart) | `_resetPasswordPaths = ['set-new-password', 'reset-password']` → `/reset-password/<token>` |
| [`lib/app/app.dart`](../../lib/app/app.dart) | `_handleDeepLink` presents `ResetPasswordScreen(token:)` directly on the navigator |
| [`lib/core/router/app_router.dart`](../../lib/core/router/app_router.dart) | Added public route `/reset-password/:token` |
| [`android/app/src/main/AndroidManifest.xml`](../../android/app/src/main/AndroidManifest.xml) | Added `android:pathPrefix="/set-new-password"` to the existing `dev.fap.rs` App Link filter |
| [`lib/l10n/app_en.arb`](../../lib/l10n/app_en.arb) / [`app_sr.arb`](../../lib/l10n/app_sr.arb) | `resetPasswordTitle`, `resetPasswordSubtitle`, `resetPasswordInvalidTitle/Description`, `requestNewLink`, `resetPasswordSuccessTitle` |

---

## Key Decisions

### 1. Reuse the registration-confirm deep-link pattern
The reset link follows the exact structure proven for registration confirmation: a
**path-parameter token** (`/reset-password/:token`, not a query param), routed by
`DeepLinkHandler`, and **presented directly on the navigator** to bypass the
`StatefulShellRoute` redirect. See [`05-email-confirm-deeplink-gorouter.md`](05-email-confirm-deeplink-gorouter.md).

### 2. The backend path and the in-app route differ (`set-new-password` → `/reset-password`)
`fap-service` emits `set-new-password` in the email, but the app route is `/reset-password`.
`DeepLinkHandler` accepts **both** `set-new-password` and `reset-password` (the latter kept as
an alias for manual testing), so the email path never has to change.

### 3. The reset screen is public and auth-independent
Like `/confirm-registration`, `/reset-password/:token` is **not** login-gated: it must render
whether or not a stale session exists. The token is the only credential.

### 4. No new `fap-infra` change was required
The reset link reuses the existing `dev.fap.rs` host, `autoVerify` intent-filter, and
`assetlinks.json`; only the `pathPrefix` in `AndroidManifest.xml` was added. One association
file serves both email flows and passkeys.

### 5. The backend returns no session after reset
`POST /v1/auth/forgotten/password` does not issue a JWT, so the success state sends the user to
Sign In rather than auto-logging in.

---

## Lessons Learned

### 1. One host, many path prefixes
Adding a second email flow was a `pathPrefix` addition to an existing intent-filter — no new
scheme, host, or `assetlinks.json` entry. Keep email paths under the same verified host.

### 2. Keep the email path out of the app route namespace
Backend copy (`set-new-password`) and the internal route (`/reset-password`) were allowed to
diverge deliberately; `DeepLinkHandler` is the single translation point. Document the mapping
so the two names are not "fixed" independently.

### 3. Reuse the existing `app_links` plumbing
`FapApp` already handled cold (`getInitialLink`) and warm (`uriLinkStream`) links for
confirmation; the reset flow only needed a second `WidgetBuilder` branch. No new lifecycle
code.

### 4. Loading + error handling on the request screen
Wiring the real `POST /v1/auth/forgotten/password/email` meant the reset button needed a
disabled/spinner state and a SnackBar on failure, matching the other auth screens.

---

## Verification

```bash
flutter analyze                     # No issues found
dart run build_runner build         # After provider/ARB changes
flutter run

# Manual deep-link test (custom scheme)
adb shell am start -a android.intent.action.VIEW \
  -d "fap://set-new-password?token=<TOKEN>"

# HTTPS App Link (the form sent in the reset email)
adb shell am start -a android.intent.action.VIEW \
  -d "https://dev.fap.rs/set-new-password?token=<TOKEN>"
```

Confirmed end-to-end: Forgot Password → email received in Gmail → tapping the link opens the
app and navigates to `ResetPasswordScreen` → set a new password → Sign In with the new
password.

---

## Follow-ups

1. **iOS Universal Links:** still absent (`apple-app-site-association` +
   `applinks:dev.fap.rs` entitlement). Both email flows are Android-only for now.
2. **Cold-start from Gmail:** verify `getInitialLink` presents the reset screen when the app is
   not already running (same open item as registration confirmation, doc 05 Lesson #5).
3. **Release signing fingerprint:** add the release cert SHA-256 to `assetlinks.json` before
   shipping release builds.
