# FAP Mobile — OpenCode Agent Instructions

## Project
**Fuel Auto Pay (FAP) Flutter Mobile Client** — ANPR-based automated fuel payment system.
Replaces the Angular/Ionic fap-client.
**Location:** `/Users/vvasic/Projects/FuelAutoPay/code/fap-mobile`
**Package:** `com.vincsoftware.fap_mobile`
**Platforms:** Android & iOS
**AI Assistant:** DeepSeek V4 via OpenCode-Local

## Technology Stack (Mandated)
- **Flutter** 3.44+ / **Dart** 3.12+
- **State:** Riverpod 3.x with `@riverpod` code-gen (riverpod_annotation + riverpod_generator)
- **Data Classes:** freezed + json_serializable (immutable models, JSON parsing)
- **Routing:** go_router 17.x (ShellRoute for bottom nav, AuthGuard redirects)
- **HTTP:** Dio 5.x (JWT interceptor, logging, error handling)
- **Secure Storage:** flutter_secure_storage 10.x (JWT tokens)
- **Passkeys/WebAuthn:** passkeys 2.x (Android Credential Manager / iOS ASAuthorizationController)
- **Maps:** google_maps_flutter 2.x
- **Push:** firebase_messaging 16.x + firebase_core
- **Social Auth:** flutter_appauth 12.x (Google + GitHub OAuth2)
- **Build Runner:** build_runner for code generation

## Architecture
**Pattern:** Feature-first with Repository + Riverpod Provider.

```
lib/
  app/              # App shell, MaterialApp.router, theme
  core/
    network/        # Dio client, interceptors, API constants
    storage/        # FlutterSecureStorage wrapper
    theme/          # Colors, typography, ThemeData from Stitch design
    widgets/        # Reusable components matching design
  features/
    auth/           # Login, register, forgot-password, passkey login
    account/        # Profile CRUD
    organization/   # Company profile CRUD
    vehicles/       # License plate CRUD
    settings/       # Passkey registration
    home/           # Dashboard shell (Phase 2)
  main.dart
```

## Backend API
**Base URL (dev):** `http://localhost:8080/api`
**Base URL (prod):** `https://dev.fng.rs/api`
**Auth:** JWT stored in FlutterSecureStorage, attached via Dio interceptor as `Authorization: Bearer {token}`.
**Login Response:** `{ access_token: string, refresh_token: string }`

### Auth Endpoints (no auth)
| POST | `/v1/auth/login` | `{ email, password }` |
| POST | `/v1/auth/registration` | `{ email, password, role: "ADMIN" }` |
| POST | `/v1/auth/confirm/registration` | `{ token }` |
| POST | `/v1/auth/forgotten/password/email` | `{ email }` |
| POST | `/v1/auth/forgotten/password` | `{ token, password, confirmedPassword }` |

### Auth Endpoints (auth required)
| POST | `/v1/auth/logout` | `{}` |
| POST | `/v1/auth/token/exchange` | `{ token }` |

### WebAuthn Endpoints (auth required)
| POST | `/webauthn/register/options` | `{}` → WebauthnRegisterOptions |
| POST | `/webauthn/register` | `{ publicKey: { credential, label } }` → `{ success }` |
| POST | `/webauthn/authenticate/options` | `{}` → WebauthnAuthenticateOptions |
| POST | `/v1/auth/login/webauthn` | assertion JSON → LoginResponseModel |

### Account Endpoints (auth required)
| GET | `/v1/account` | → AccountModel |
| POST | `/v1/account` | AccountModel |
| PUT | `/v1/account/{accountId}` | AccountModel |
| GET | `/v1/account/{accountId}/organization/{orgId}` | → OrganizationModel |
| POST | `/v1/account/{accountId}/organization` | OrganizationModel |
| PUT | `/v1/account/{accountId}/organization/{orgId}` | OrganizationModel |

### OAuth2 URLs (browser redirect)
| GET | `/{base}/oauth2/authorization/google?redirect_uri={origin}/login` |
| GET | `/{base}/oauth2/authorization/github?redirect_uri={origin}/login` |

### Data Models (use freezed for all)
```
LoginResponseModel { access_token, refresh_token }
AccountModel { firstName?, lastName?, phone?, address?, city?, zip?, country?, authUserId?, id?, organizationId? }
OrganizationModel { id?, name?, crn?, vat?, phone?, email?, address?, city?, zip?, country?, accountId? }
VehiclePlateModel { id?, number?, registrationDate?, city?, country?, accountId? }
ErrorModel { timestamp, status, error: { message }, trace, message, path }
```

### Error Response
```json
{ "timestamp": "...", "status": 400, "error": { "message": "..." }, "trace": "...", "message": "...", "path": "..." }
```

## MVP Features (Phase 1)
1. **Auth:** Login, Registration, Email confirmation, Forgot password, Reset password, Passkey login, Social login (Google, GitHub)
2. **Account:** Profile CRUD (firstName, lastName, phone, address, city, zip, country)
3. **Organization:** Profile CRUD (name, crn, vat, phone, email, address, city, zip, country)
4. **License Plates:** List, add, edit, delete plates
5. **Settings:** Add Passkey (WebAuthn registration)

## Implementation Order
1. Project scaffolding + core layer (Dio, storage, theme, router)
2. Auth feature (screens + providers + API calls)
3. Account feature
4. Organization feature
5. License plates feature
6. Settings (passkey registration)

## Design
Apply **Google Stitch** exports from `design/` directory:
- Colors + typography → `lib/core/theme/`
- Component specs → `lib/core/widgets/`
- Screen layouts → each screen widget

## Design Token Extraction Rule
**All design tokens (colors, typography, spacing, radius) MUST be defined as named constants
in `lib/core/theme/` files.** Widgets and screens MUST reference these constants rather than
hardcoding raw values.

| Token type | File | Example |
|---|---|---|
| Colors | `app_colors.dart` | `lightColorScheme.primary`, `vibrantCyan`, `glassBorderLight` |
| Typography | `app_typography.dart` | `appTextTheme.bodyMedium` |
| Spacing | `app_dimensions.dart` | `AppDimensions.stackMd` |
| Border radius | `app_dimensions.dart` | `AppDimensions.radiusLg` |
| Component-specific | `app_colors.dart` | `glassBorderLight`, `surfaceGlassLight` |

**Anti-pattern (DO NOT):**
```dart
border: Border.all(color: const Color(0x1A00696E))
```
**Correct pattern (DO):**
```dart
border: Border.all(color: glassBorderLight)
```

If a new design value does not have a corresponding constant, add it to the appropriate
theme file first, then reference it. Never embed raw design values in widget files.

## Typography & Style Reuse Rules

**Rule 1: Use appTextTheme styles directly.**
Do NOT use `copyWith` to re-specify properties that already match the base style
in `app_typography.dart`. The base style already defines fontSize, fontWeight,
height, and letterSpacing for each text style.

**Anti-pattern (DO NOT):**
```dart
style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600)
```
**Correct pattern (DO):**
```dart
style: theme.textTheme.displaySmall
```
(displaySmall already has `fontWeight: FontWeight.w600` in app_typography.dart)

**Rule 2: Use `copyWith` only for theme-adaptive or cross-theme overrides.**
When you need different colors or decoration from the base style, `copyWith` is
acceptable — but only override the properties that actually differ.

✅ **Acceptable:**
```dart
style: theme.textTheme.displayLarge?.copyWith(color: brandPrimary)
```
(only color differs; fontSize, fontWeight, height all come from the base style)

**Rule 3: Use named constants from `app_colors.dart` for cross-theme consistency.**
For text that should appear the same in both light and dark themes (brand name,
links, call-to-action text), use a named color constant like `brandPrimary` or
`vibrantCyan`. Use `theme.colorScheme.onSurfaceVariant` only when the color
should adapt to the current theme (e.g., secondary text).

✅ **Cross-theme (same in both themes):**
```dart
style: theme.textTheme.bodySmall?.copyWith(color: brandPrimary)
```
✅ **Theme-adaptive (different in each theme):**
```dart
style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)
```

**Rule 4: Prefer theme-level button styles over per-screen overrides.**
Button textStyle, foregroundColor, and backgroundColor should be defined in
`app_theme.dart` `elevatedButtonTheme` / `outlinedButtonTheme` whenever possible.
Per-screen overrides are acceptable only when a specific button instance needs
a different style from the theme default.

**Rule 5: Use `linkMedium` / `linkSmall` constants for all link text.**
All clickable link text MUST use either `linkMedium` (inline action links)
or `linkSmall` (footer/secondary links) from `app_typography.dart`. Color is
applied via `copyWith` — `brandPrimary` for action links, `theme.colorScheme.onSurfaceVariant`
for footer links.

**Anti-pattern (DO NOT):**
```dart
style: theme.textTheme.bodySmall?.copyWith(
  color: brandPrimary,
  fontWeight: FontWeight.w600,
)
```

**Correct pattern (DO):**
```dart
style: linkMedium.copyWith(color: brandPrimary)
```

**Footer links (Privacy Policy, Terms of Service):**
```dart
style: linkSmall.copyWith(color: theme.colorScheme.onSurfaceVariant)
```

## Localization Rules

**Rule 1: All user-facing strings MUST come from ARB files.**
Never hardcode user-facing text in widgets. Every string must be defined in both
`lib/l10n/app_en.arb` (English) and `lib/l10n/app_sr.arb` (Srpski) and accessed
via `AppLocalizations.of(context)!`.

**Anti-pattern (DO NOT):**
```dart
Text('SIGN IN')
```

**Correct pattern (DO):**
```dart
final l10n = AppLocalizations.of(context)!;
...
Text(l10n.signIn)
```

**Rule 2: Add new strings to both ARB files simultaneously.**
When adding a new screen or UI string, always update `app_en.arb` and `app_sr.arb`
in the same commit. The key name should follow camelCase convention and describe
the string's purpose (e.g., `validationEmailRequired`, `forgotPasswordTitle`).

**Rule 3: Regenerate after ARB changes.**
After modifying `.arb` files, run `flutter pub get` (which triggers code generation
via `flutter: generate: true` in pubspec.yaml). The generated output goes to
`lib/l10n/app_localizations.dart`.

**Rule 4: Use `@` metadata annotations in ARB for description context.**
For strings that need translation context, include `@keyName` metadata with a
`description` field to guide translators.

**Example:**
```json
{
  "resetPassword": "RESET PASSWORD",
  "@resetPassword": {
    "description": "Button label on the forgot password screen to send a reset email"
  }
}
```

## Card Component Convention

**Rule: Use `GlassCard` for all card/container elements across the app.**
Every form card, information card, or content container MUST use the `GlassCard`
widget from `lib/features/auth/presentation/widgets/glass_card.dart`. This ensures
consistent border radius (`AppDimensions.radiusLg` = 12px), glass backdrop effect,
and border styling across all screens.

**Anti-pattern (DO NOT):**
```dart
ClipRRect(
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(24),
    topRight: Radius.circular(24),
  ),
  child: Container(
    color: Colors.white,
    child: ...
  ),
)
```

**Correct pattern (DO):**
```dart
GlassCard(
  child: Form(
    ...
  ),
)
```

Exceptions must be documented with a comment explaining why a custom card is necessary.

## Button Tier Convention

| Tier | Widget | Background | Foreground | Used for |
|---|---|---|---|---|
| Primary | `ElevatedButton` | `vibrantCyan` | `brandPrimary` | SIGN IN, SIGN UP, SAVE, CONFIRM (call-to-action) |
| Secondary | `OutlinedButton` | `colorScheme.surfaceContainerLow` | `colorScheme.onSurface` | BIOMETRIC SIGN IN, social login, CANCEL, SKIP |
| Text | `TextButton` | transparent | `brandPrimary` | "Forgot password?", "Sign up now" (inline links) |

**Rule 1: All primary `ElevatedButton` widgets MUST use the exact same style.**
Every primary submit/action button in the app must have:
```dart
style: ElevatedButton.styleFrom(
  backgroundColor: vibrantCyan,
  foregroundColor: brandPrimary,
  padding: const EdgeInsets.symmetric(vertical: 16),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
  ),
  elevation: 0,
),
child: Text(
  label,
  style: theme.textTheme.displaySmall?.copyWith(color: brandPrimary),
),
```
This ensures SIGN IN, CREATE ACCOUNT, RESET PASSWORD, SAVE, and CONFIRM buttons all look identical. Do NOT use `radiusFull` (pill shape) or custom text styles for primary buttons.

**Rule 2:** All secondary `OutlinedButton` widgets MUST set
`backgroundColor: theme.colorScheme.surfaceContainerLow` to match the input field fill color.

## Verification
```bash
flutter analyze   # Zero errors
flutter test      # All passing
```
