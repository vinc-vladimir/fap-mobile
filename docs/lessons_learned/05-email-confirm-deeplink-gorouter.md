# Email Confirmation Deep Link + go_router Redirect Pitfalls — Lessons Learned

## Overview

This phase made the **email registration confirmation** flow work end-to-end and
fixed **Sign In → Home** navigation. The confirmation is triggered by the
`fap://registration-confirm?token=…` deep link the backend embeds in the
confirmation email. On a real phone the user taps that link in the mail app and
the app opens and confirms automatically; `adb` was only a **test substitute**
for that mail-app tap (as in Lesson #04).

Three distinct bugs were found and fixed along the way:

1. The confirm screen never opened from the deep link — a go_router
   `StatefulShellRoute` redirect hijacked logged-out top-level navigation.
2. Repeated deep links were ignored because the token was a **query** param, so
   the same route path was reused and a stale screen (bound to the first token)
   stayed on top.
3. Sign In wouldn't navigate to Home — the router guard read an **async** auth
   state that returned a stale cached `false` after login.

---

## Files Created / Modified

| File | Purpose |
|---|---|
| [`lib/app/app.dart`](../../lib/app/app.dart) | Deep links now present the confirm screen directly on the navigator (`router.routerDelegate.navigatorKey`) to bypass go_router's redirect; added `[DeepLink]` logs |
| [`lib/core/deep_links/deep_link_handler.dart`](../../lib/core/deep_links/deep_link_handler.dart) | Routes `fap://registration-confirm?token=…` → `/confirm-registration/<token>` (path param); added `[DeepLinkHandler]` logs |
| [`lib/core/router/app_router.dart`](../../lib/core/router/app_router.dart) | Confirm route is `/confirm-registration/:token` and is **not** login-gated; redirect reads synchronous `authStateProvider`; `router.refresh()` on auth change; `[RouterRedirect]` logs |
| [`lib/features/auth/presentation/providers/auth_providers.dart`](../../lib/features/auth/presentation/providers/auth_providers.dart) | `authState` → synchronous `AuthState` Notifier; `LoginController` updates it on login/logout; `confirmRegistration` is `@Riverpod(keepAlive: true)` |
| [`lib/features/auth/presentation/screens/confirm_registration_screen.dart`](../../lib/features/auth/presentation/screens/confirm_registration_screen.dart) | Pops the pushed confirm overlay then routes to Sign In (`_goToSignIn`); `[ConfirmRegistrationScreen]` log |

---

## Key Decisions

### 1. Email confirmation is production-ready, not an `adb` workaround
The email link is `fap://registration-confirm?token=…`. app_links delivers it to
`_handleDeepLink` in `app.dart` via `getInitialLink` (cold start) or
`uriLinkStream` (warm start) — **identical** whether the user taps the link in
the mail app or it is injected with `adb`. There is no adb-specific path.
Confirmed end-to-end: Sign Up → tap/inject link → "Account Activated"
(`email_verified=true` in DB) → Sign In → Home → Sign Out.

### 2. The confirm screen bypasses go_router for the deep link
go_router 17.x, when navigating to a **top-level** route while **logged out**,
re-evaluates the `StatefulShellRoute` home branch `/`. That branch's redirect
(`!loggedIn && isProtected → /sign-in`) **hijacks** the navigation, so
`router.go('/confirm-registration/…')` resolves to `/sign-in` and the confirm
screen never builds. The fix presents the screen directly on the navigator:

```dart
router.routerDelegate.navigatorKey.currentState!.push(
  MaterialPageRoute<void>(builder: (_) => ConfirmRegistrationScreen(token: token)),
);
```

This bypasses the redirect entirely. It works, but it is a **pragmatic
workaround** for a go_router quirk — a cleaner go_router-native navigation
(route refresh / replacement) could replace it later.

### 3. Confirmation is a public, auth-independent action
`/confirm-registration` must **never** be in the login-gated `_authLocations`.
If it is, a stale/leftover session makes the guard redirect a logged-in user to
`/` and the confirm call is silently swallowed. It must render whether or not a
session exists. `/reset-password` will follow the same rule.

### 4. Deep-link token must be a path parameter, not a query parameter
With `/confirm-registration?token=A`, another link `?token=B` matches the **same
route path**; go_router reuses the already-mounted screen bound to `A`, so `B`
is ignored (we observed a confirm POST with the *previous* token). Using a path
segment `/confirm-registration/:token` makes each token a distinct location and
forces a fresh screen + fresh call.

### 5. Router guard needs synchronous auth state
The redirect read `authStateProvider.value` — an **async** `Future<bool>` that
stayed cached at `false` after login wrote the token. So `context.go('/')` after
Sign In saw `loggedIn=false`, treated `/` as protected, and bounced back to
`/sign-in`. Fix: `authState` is now a synchronous `AuthState` `Notifier`
(restored from storage on build, updated in-memory by login/logout), and the
router calls `router.refresh()` on auth changes so login, logout, and cold-start
session restore all navigate correctly.

### 6. Confirm provider must be `keepAlive`
The confirm provider is a family keyed by token. Auto-dispose re-fires the
request every time the screen rebuilds — with a valid (single-use) OTT the first
call returns 200 (consuming the token), then a rebuild re-runs it and flips the
screen from "Account Activated" to "Confirmation Failed" (400 "already
consumed"). `@Riverpod(keepAlive: true)` caches the per-token result.

### 7. Do not clear stored tokens inside the confirm provider
`clearTokens()` was added to the confirm provider defensively. Because the
endpoint is `permitAll` and the call previously worked without it, removing it
is correct; clearing first once silently blocked the request. Any stale-session
cleanup belongs *after* a successful confirm, never before the call.

---

## Lessons Learned

### 1. A go_router `redirect` runs on every navigation and can hijack siblings
With a `StatefulShellRoute`, navigating to a top-level route while logged out can
re-run the shell's `/` redirect and send the whole navigation to `/sign-in`.
`redirect` is evaluated per-location in the route tree, not just for the exact
target — so a branch's redirect can win. Bypass the redirect for genuinely
top-level, auth-independent destinations (or restructure so they aren't
siblings of a protected shell route).

### 2. Query-only route changes don't recreate the page
`go('/x?token=A')` → `go('/x?token=B')` matches the same route; the mounted
screen is reused and keeps the old value. Prefer path parameters for identity
that must change per navigation.

### 3. Async auth providers break synchronous redirects
A `Future<bool>` auth state read with `.value ?? false` defaults to `false`
while loading and stays stale after a write. Redirects (and any "is the user
logged in" check right after a mutation) need a **synchronous** source updated
in-memory. Use a `Notifier` updated by the login/logout controller and call
`router.refresh()` when it changes.

### 4. Single-use OTTs demand one-shot providers
Anything that consumes a one-time token must run exactly once per token.
Auto-dispose providers re-run on rebuild and will re-consume/error. `keepAlive`
(or manual result caching) is required.

### 5. Verify the real cold-start path
Our deep-link tests were warm-start (`uriLinkStream`). The cold-start path
(`getInitialLink`) pushes onto the navigator from `initState`; if the navigator
isn't ready, `currentState` may be `null` and the code falls back to
`router.go()` (which hijacks). Worth verifying with a truly cold start.

---

## Verification

```bash
flutter analyze                     # No issues found
flutter test                        # All passing
dart run build_runner build         # After provider/ARB changes
adb shell am start -a android.intent.action.VIEW \
  -d "fap://registration-confirm?token=<TOKEN>"   # Manual deep-link test
```

Confirmed end-to-end: Sign Up → copy deep link from backend log → `adb` inject
(equals the mail-app tap) → `ConfirmRegistrationScreen` ("Account Activated",
`email_verified=true`) → Sign In → Home → Sign Out.

---

## Follow-ups

1. **HTTPS universal links** (custom scheme → `fap://`) — `assetlinks.json`
   (Android) / `apple-app-site-association` (iOS) are more robust in production
   (no "Open with?" prompt, reliable cold start, stronger `autoVerify`).
2. **Verify cold-start deep link** — confirm `getInitialLink` pushes the confirm
   screen when the navigator is available (see Lesson #5 above).
3. **Prefer a cleaner go_router-native confirm navigation** once the
   `StatefulShellRoute` redirect quirk is better understood or upgraded away.
4. **Forgot-password deep link** (`fap://reset-password`) — reuse the same
   `app_links` plumbing + path-param pattern; backend `FORGOTTEN_PWD_URL` is
   already configurable.
