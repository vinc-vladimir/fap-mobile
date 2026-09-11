# Registration Confirmation via HTTPS App Link — Lessons Learned

## Overview

This phase made the **registration-confirmation link tappable from the email** by moving it
from a custom scheme to an **HTTPS Android App Link**:

- Before: `fap://registration-confirm?token=…`
- After: `https://dev.fap.rs/registration-confirm?token=…`

Gmail on Android only linkifies `http(s)`, `tel`, and `mailto` — a `fap://` URL in the message
body is inert text, so it could not be tapped. A verified **HTTPS App Link** is the supported
way to open the app from an email. The old `fap://` filter is retained for `adb` testing and
back-compat.

The Flutter side needed **no Dart change**: `DeepLinkHandler.routeForUri` already read
`uri.path` for non-custom-scheme links and maps both forms to `/confirm-registration/<token>`.

> **Status:** the mobile App Link is implemented and verified via `adb`. The **`fap-service`
> email change is not yet applied** — the service still runs at `localhost` and its
> `reg-confirm-url` default remains `fap://…`. Switching the email link to the HTTPS URL is
> handed off to the `fap-service` agent (see Follow-ups).

---

## Cross-Repo Ownership

This feature spans three repositories. Per `AGENTS.md`, only the owning project's agent may
change each one; the others are handed off.

| Artifact | Repo | Change |
|---|---|---|
| `static/.well-known/assetlinks.json` | **fap-infra** | Added `delegate_permission/common.handle_all_urls` (kept `get_login_creds` for passkeys) |
| `android/app/src/main/AndroidManifest.xml` | **fap-mobile** | Added an `https` + `host=dev.fap.rs` + `pathPrefix=/registration-confirm` + `autoVerify` intent-filter |
| `reg-confirm-url` + email body | **fap-service** | Point the confirmation link at `https://dev.fap.rs/registration-confirm?token=` (pending) |

---

## Files Created / Modified

| File | Purpose |
|---|---|
| [`android/app/src/main/AndroidManifest.xml`](../../android/app/src/main/AndroidManifest.xml) | Second intent-filter for the HTTPS App Link (host `dev.fap.rs`, path prefix `/registration-confirm`, `autoVerify`) |
| [`lib/core/deep_links/deep_link_handler.dart`](../../lib/core/deep_links/deep_link_handler.dart) | Unchanged — already reads `uri.path` for https and maps to `/confirm-registration/<token>` |
| [`lib/app/app.dart`](../../lib/app/app.dart) | Unchanged — `app_links` cold/warm handling already presents the confirm screen |
| `fap-infra: static/.well-known/assetlinks.json` | App Links relation with the app package + debug cert fingerprint |
| `fap-service: src/main/resources/application.yml` | `REG_CONFIRM_URL=https://dev.fap.rs/registration-confirm?token=` (pending) |
| `fap-service: .../notification/email/service/EmailServiceImpl.java` | Render the link as an HTML anchor (pending) |

---

## Key Decisions

### 1. Use a verified HTTPS App Link for the email link
Custom schemes are not tappable in Gmail. `https://dev.fap.rs/registration-confirm?token=…`
is linkified by Gmail and, once verified, Android opens the app directly instead of a browser.

### 2. Keep the custom `fap://` filter for `adb` and back-compat
The `fap` scheme filter stays in `AndroidManifest.xml` (and `fap://` remains usable via
`adb shell am start`). Both URIs route to the same screen, so there is one code path to test.

### 3. The App Link / association domain is `dev.fap.rs`
`dev.fap.rs` is the TEST domain (per `fap-infra`), it already serves
`/.well-known/assetlinks.json`, and its SHA-256 fingerprint matches the Android **debug**
keystore — so debug builds verify without extra work.

### 4. The backend email URL stays configurable
`fap-service` builds the link from `email-configuration.reg-confirm-url` (env
`REG_CONFIRM_URL`). Moving to https is a config/format change, not a new endpoint.

---

## Lessons Learned

### 1. Gmail does not linkify custom schemes
A `fap://…` string in an HTML email is not tappable in Gmail. Do not rely on it for real users;
use an HTTPS App Link / Universal Link.

### 2. App Links verification is install-time and fingerprint-bound
Android fetches `https://<host>/.well-known/assetlinks.json` at install time and matches the
installed app's signing certificate. The debug cert fingerprint
(`C5:C3:B1:4B:…:4F:08:F1`) must be present; a **release** build will need its own fingerprint
added. Verification also requires the emulator/device to reach the host over HTTPS.

### 3. `autoVerify` alone does nothing without a host
The pre-existing `fap` filter had `android:autoVerify="true"` but no `android:host`, so it was
never a real App Link. Verification requires `scheme` **and** `host` (and optionally `pathPrefix`).

### 4. Manifest / assetlinks changes need a reinstall and re-verify
Hot reload does not pick these up. Reinstall the app, then:
`adb shell pm verify-app-links --re-verify com.vincsoftware.fap_mobile`.

### 5. One screen, two entry URIs
`fap://registration-confirm?token=…` (host carries the route) and
`https://dev.fap.rs/registration-confirm?token=…` (path carries the route) both resolve to
`/confirm-registration/<token>` in `DeepLinkHandler`. Keep the path check
(`path.contains('registration-confirm')`) working for both.

### 6. `assetlinks.json` is shared with passkeys
The same file carries `get_login_creds` (WebAuthn/passkeys) and `handle_all_urls` (App Links).
Editing it for one feature must not drop the other relation.

---

## Verification

```bash
flutter run
adb shell pm verify-app-links --re-verify com.vincsoftware.fap_mobile
adb shell pm get-app-links com.vincsoftware.fap_mobile   # dev.fap.rs should be "verified"
adb shell am start -a android.intent.action.VIEW \
  -d "https://dev.fap.rs/registration-confirm?token=<TOKEN>"
```

Confirmed: the HTTPS link opens the app and reaches `ConfirmRegistrationScreen`. The full
"tap the link in Gmail" path is blocked only on the pending `fap-service` email change.

---

## Follow-ups

1. **`fap-service` (hand-off):** default `REG_CONFIRM_URL` to
   `https://dev.fap.rs/registration-confirm?token=` and render the link as an HTML anchor
   (localized label). Until then, mail still carries the `fap://` link.
2. **iOS Universal Links:** add `applinks:dev.fap.rs` to `Runner.entitlements` and host
   `apple-app-site-association` at `https://dev.fap.rs/.well-known/` (absent today).
3. **Release signing fingerprint:** add the release cert SHA-256 to `assetlinks.json` before
   shipping release builds.
4. **Forgot-password App Link:** reuse this pattern for `forgotten-password-url`.
5. **Cold-start from Gmail:** verify `getInitialLink` presents the confirm screen when the app
   is not already running (see `05-email-confirm-deeplink-gorouter.md`, Lesson #5).
