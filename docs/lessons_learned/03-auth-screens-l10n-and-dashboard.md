# Auth Screens, Localization & Dashboard Shell — Lessons Learned

## Overview

This phase built on the phase-02 design system to deliver the full **unauthenticated
auth flow** (sign in, sign up, forgot password, email sent, legal screens), added
**English + Serbian localization (l10n)** via ARB files, extracted shared auth
widgets, and started the **Phase-2 dashboard shell** (home + account screens, WIP on
branch `initial-home-screen`). The `design/` folder remains the single source of
truth; each new screen mirrors a Stitch export under `design/<screen>/`.

---

## Files Created / Modified

| File | Purpose |
|---|---|
| [`lib/features/auth/presentation/screens/sign_in_screen.dart`](../../lib/features/auth/presentation/screens/sign_in_screen.dart) | Sign in form (email, password, biometric, social, legal footer). Validates then navigates to `HomeScreen` |
| [`lib/features/auth/presentation/screens/sign_up_screen.dart`](../../lib/features/auth/presentation/screens/sign_up_screen.dart) | Create-account form with live password requirements checklist |
| [`lib/features/auth/presentation/screens/forgot_password_screen.dart`](../../lib/features/auth/presentation/screens/forgot_password_screen.dart) | Email-only reset request form → `EmailSentScreen` |
| [`lib/features/auth/presentation/screens/email_sent_screen.dart`](../../lib/features/auth/presentation/screens/email_sent_screen.dart) | "Check Your Email" confirmation with `digital_envelope.png` hero |
| [`lib/features/auth/presentation/screens/privacy_policy_screen.dart`](../../lib/features/auth/presentation/screens/privacy_policy_screen.dart) | Static legal content, `AppBar` + scrollable sections |
| [`lib/features/auth/presentation/screens/terms_of_service_screen.dart`](../../lib/features/auth/presentation/screens/terms_of_service_screen.dart) | Static legal content, `AppBar` + scrollable sections |
| [`lib/features/auth/presentation/widgets/glass_card.dart`](../../lib/features/auth/presentation/widgets/glass_card.dart) | Reusable glassmorphism card (blur 20, `radiusLg`, `surfaceGlassLight/Dark`) |
| [`lib/features/auth/presentation/widgets/hero_background.dart`](../../lib/features/auth/presentation/widgets/hero_background.dart) | 40% viewport-height hero image with gradient fade to surface |
| [`lib/features/auth/presentation/widgets/or_divider.dart`](../../lib/features/auth/presentation/widgets/or_divider.dart) | "OR CONTINUE WITH" divider row |
| [`lib/features/auth/presentation/widgets/social_button.dart`](../../lib/features/auth/presentation/widgets/social_button.dart) | Google/GitHub `OutlinedButton` driven by a `SocialProvider` enum |
| [`lib/core/widgets/brand_title.dart`](../../lib/core/widgets/brand_title.dart) | Stroke-text brand (outlined `brandPrimary` + `fillColor` stack) |
| [`lib/features/auth/data/validation_constants.dart`](../../lib/features/auth/data/validation_constants.dart) | Shared `emailRegex`, `passwordRegex`, char-class regexes |
| [`lib/l10n/`](../../lib/l10n/) | `app_en.arb` + `app_sr.arb` and generated `app_localizations*.dart` |
| [`l10n.yaml`](../../l10n.yaml) | flutter_localizations config (`arb-dir`, `template-arb-file`, `output-dir`) |
| [`lib/features/home/presentation/screens/home_screen.dart`](../../lib/features/home/presentation/screens/home_screen.dart) | Dashboard shell (WIP): points gauge, station card, rewards, bottom nav |
| [`lib/features/account/presentation/screens/account_screen.dart`](../../lib/features/account/presentation/screens/account_screen.dart) | Account shell (WIP): change-password + sign-out action tiles |
| [`assets/images/digital_envelope.png`](../../assets/images/digital_envelope.png) | Email-sent hero, copied from [`design/email_sent/`](../../design/email_sent/) |
| [`design/home_screen/`](../../design/home_screen/) | Stitch export for the dashboard (Velocity Blue palette) |

---

## Key Decisions

### 1. Google Fonts adopted (resolves phase-02 item #3)
[`app_typography.dart`](../../lib/core/theme/app_typography.dart) now wraps
`GoogleFonts.interTextTheme(...)` instead of a bare `fontFamily: 'Inter'`. The
`linkMedium` / `linkSmall` text styles stay as raw `TextStyle` constants (they are
also used inside the GoogleFonts tree but defined separately — see AGENTS Rule 5).

### 2. Localization via `flutter gen-l10n`, not build_runner
l10n uses Flutter's built-in generator. Additions to the ARB files are regenerated
with `flutter gen-l10n` (or `flutter pub get`), producing
`app_localizations.dart` + per-locale files. **Generated files are committed** to
the repo — do not hand-edit them; edit only the `.arb` sources.

### 3. Placeholder strings need ARB `@key` metadata
Parameterized strings like `pointsUntilSilver`, `distanceAway`, and `afterRefuels`
use `{placeholder}` syntax in the ARB value. The generator infers parameters from
the placeholders. (For descriptions, add an `@key` block; the current ARB files omit
most of these — acceptable but a candidate for cleanup.)

### 4. Shared auth widgets extracted early
`GlassCard`, `HeroBackground`, `OrDivider`, `SocialButton` live under
`features/auth/presentation/widgets/` and are reused across all auth screens.
`BrandTitle` (stroke-text brand) lives in `core/widgets/` because it is app-wide.
Rule of thumb: auth-only widgets stay in the feature; cross-feature widgets go to
`core/`.

### 5. SocialButton is enum-driven
`SocialProvider { google, github }` maps `provider.name` → label (uppercased) and
`assets/images/${provider.name}_logo.png`. This forced the asset rename from
`Google_logo.png` → `google_logo.png` and `GitHub_logo.png` → `github_logo.png` to
match `provider.name` casing.

### 6. Validation constants are top-level finals
[`validation_constants.dart`](../../lib/features/auth/data/validation_constants.dart)
exposes `emailRegex` and `passwordRegex` as shared top-level finals rather than
per-widget. The password rule enforced is:
`(?=.*\d)(?=.*[A-Z])(?=.*[a-z])(?=.*[^\w\s:])(\S){8,}` — one digit, upper, lower,
special, 8+ chars, no whitespace.

### 7. Navigation is still `Navigator.push` (no go_router yet)
Despite go_router 17.x being in `pubspec.yaml`, screens transition with
`MaterialPageRoute`. Sign in uses `Navigator.pushReplacement` to reach
`HomeScreen`; the account screen is reached from the bottom nav. The go_router
refactor (ShellRoute + AuthGuard) is a known follow-up.

### 8. Dashboard is hand-built, not yet a go_router ShellRoute
`HomeScreen` implements a custom floating bottom nav (`Positioned` container) and a
custom `_HomeAppBar` instead of `Scaffold` + `NavigationBar`. This matches the Stitch
`design/home_screen/code.html` visuals (glass nav, glow accents) but duplicates
safe-area handling per screen (`MediaQuery.padding.top`). Refactoring to
`Scaffold`/`NavigationBar` or a `ShellRoute` is deferred.

### 9. Hardcoded hex values crept back into widgets
Per AGENTS design-token rule, colors like `Color(0xFF00DCE5)` (dark accent),
`Color(0xB31A2130)`, `Color(0xFF273647)`, and `Color(0xFF0d1c2d)` appear directly in
`home_screen.dart` / `account_screen.dart` **without** a named constant. These
should be promoted into `app_colors.dart` (e.g., a `darkAccent` / `cardDark` /
`stationMapDark` constant) before commit. This is the main anti-pattern flagged in
this phase.

---

## Lessons Learned

### 1. Uppercasing the brand broke the smoke test
The default `test/widget_test.dart` asserts `find.text('Fuel Auto Pay')`. After the
`BrandTitle` commit changed the brand to `FUEL AUTO PAY` (uppercase), the test fails:

```
Expected: at least one matching candidate
Actual: _TextWidgetFinder:<Found 0 widgets with text "Fuel Auto Pay": []>
```

**Fix:** `flutter test` is red on `initial-home-screen`. Update the test to match the
new rendered string (or assert against the localized `appTitle`). Lesson: **any
change to visible text tokens must be mirrored in widget tests.**

### 2. `flutter analyze` is the only green gate right now
`flutter analyze` → **No issues found**. `flutter test` → **failing** (see above).
Always run both before declaring a phase complete (AGENTS Verification section).

### 3. Hero top-offset differs per screen
Sign in uses `screenHeight * 0.32`, forgot password `0.35`, email sent `0.35`,
sign up `0.20` (taller form, so the card starts higher). These magic fractions are
fine for now but a single shared `HeroBackground` `topInset` param would be cleaner.

### 4. OutlinedButton content needs explicit `Row`
Outlined/Secondary buttons (`BiometricButton`, `SocialButton`) center an icon + label.
An `OutlinedButton` child does not center content the way `ElevatedButton` text does;
each uses an explicit `Row(mainAxisAlignment: center)`. If you use
`labelMedium`/`displaySmall` for button text, override nothing — the theme already
sets the style (AGENTS Rule 4).

### 5. `mainAxisAlignment` and `spaceBetween` are not used for footer
The sign-in footer is a plain `Column` of two `Row`s after the card, not the
`spaceBetween` approach suggested in phase-02 guidelines. Fine for the current
layout, but revisit when the footer needs to pin to the bottom on tall screens.

### 6. l10n keys are English-first, Serbian in tandem
Every string was added to `app_en.arb` and `app_sr.arb` simultaneously. Serbian
uses Latin script (`đ`, `š`, `ž`, `č`, `ć`) — no `_Latn` suffix needed. Decimal
comma vs dot differs (`1,240` EN vs `1.240` SR) — locale-aware formatting is a
follow-up, not handled by raw ARB strings.

### 7. `withValues(alpha:)` replaced `withOpacity`
The codebase uses the newer `Color.withValues(alpha: x)` API (opacity deprecation),
consistent with Flutter 3.44+. Don't introduce `withOpacity`.

### 8. Case-sensitivity in asset names is a footgun
Linux/CI filesystems are case-sensitive; `SocialButton` builds asset paths from
`provider.name`. Keep asset filenames lowercase to match — this already forced a
rename in commit `8d6a223`.

---

## Design Token → Widget Reference (auth + dashboard)

| Design intent | Widget / Constant | Notes |
|---|---|---|
| Glass form card | `GlassCard` | Blur 20, `radiusLg`, `surfaceGlassLight/Dark` |
| Hero image | `HeroBackground(imagePath:)` | Defaults to `sports_car_refueling.png`; `email_sent` passes `digital_envelope.png` |
| Primary CTA | `ElevatedButton` + `vibrantCyan` | Exact style mandated in AGENTS Button Tier table |
| Secondary CTA | `OutlinedButton` + `surfaceContainerLow` | Biometric, social, navigate |
| Inline links | `linkMedium` / `linkSmall` + `copyWith(color: vibrantCyan)` | AGENTS Rule 5 |
| Stroke-text brand | `BrandTitle` | Outline `brandPrimary` + fill `vibrantCyan` |
| Dark accent | **promote to constant** | Currently raw `Color(0xFF00DCE5)` in home/account |
| Dashboard cards | `Container` + `radiusXxl` (24) | `surfaceGlassLight` / `Color(0xB31A2130)` |
| Progress gauge | `CustomPaint` (`_CircularProgressPainter`) | Track 10% opacity, progress `accentColor` |

---

## Verification

```bash
flutter analyze        # No issues found
flutter test           # FAILING — widget_test expects "Fuel Auto Pay", app renders "FUEL AUTO PAY"
flutter gen-l10n       # Regenerate localizations after ARB edits
```

---

## Follow-ups

1. **Fix `widget_test.dart`** to match the uppercase brand (and ideally assert the
   localized `appTitle`).
2. **Promote dashboard hex values** to named constants in
   `app_colors.dart` (AGENTS token rule).
3. **Migrate to go_router** (`MaterialApp.router`, `ShellRoute` for home/account,
   `AuthGuard`).
4. **Replace hand-rolled bottom nav / app bar** with `Scaffold` +
   `NavigationBar` (or keep custom, but share safe-area handling).
5. **Add `@key` descriptions** for parameterized ARB strings; consider
   `intl`-style number formatting for the SR locale.
6. **Implement real auth** — repositories, providers, and Dio/secure-storage wiring
   are still missing; screens currently navigate on fake validation only.
