# FAP Mobile — OpenCode Agent Instructions

## Project
**Fuel Auto Pay (FAP) Flutter Mobile Client** — ANPR-based automated fuel payment system.
Replaces the Angular/Ionic fap-client.
**Location:** `/Users/vvasic/Projects/FuelAutoPay/code/fap-mobile`
**Package:** `com.vincsoftware.fap_mobile`
**Platforms:** Android & iOS
**AI Assistant:** DeepSeek V4 via OpenCode-Local

## Cross-Project Changes — Hand Off to the Owning Project's Agent (MANDATORY)

FAP is a multi-repository platform. Each repository has its **own dedicated agent** and
its own `AGENTS.md`, and that agent is the only one allowed to change its repository:

| Repository   | Scope                                                        | Path (MCP filesystem root `/workspace`)            |
|--------------|--------------------------------------------------------------|----------------------------------------------------|
| `fap-service`| Spring Boot backend / REST API / email                       | `/workspace/FuelAutoPay/code/fap-service`          |
| `fap-client` | Angular/Ionic web console                                    | `/workspace/FuelAutoPay/code/fap-client`           |
| `fap-mobile` | Flutter mobile client                                        | `/workspace/FuelAutoPay/code/fap-mobile`           |
| `fap-infra`  | Terraform AWS infra + static hosting (e.g. `.well-known/…`)  | `/workspace/FuelAutoPay/code/fap-infra`            |

**Rule 1: NEVER implement changes in another project's repository.**
If the task requires a change outside this repository (an endpoint, DTO, email link, DNS
record, static/association file, Terraform resource, CI config, etc.), do NOT edit it and do
NOT run host-path commands against it. Hand it off instead.

**Rule 2: Produce a self-contained hand-off prompt for the owning project's agent.**
The recipient agent has no access to this conversation. The prompt MUST state the WHAT and
WHY, and leave the HOW to the owner. It MUST contain:
1. **Goal** — the feature/behaviour being built and the end-to-end outcome.
2. **What is needed from the target project** — the exact contract/artifact (HTTP method +
   path, request/response shape, URL/host, file path, resource) and why it is needed.
3. **Explicitly leave implementation to the owner** — describe the required outcome, not the
   code; the owning agent decides how to implement it in its repository.

**Rule 3: Resolve the target project's real contract before writing the prompt.**
Read the target project under `/workspace` ONLY with the `filesystem_*` MCP tools — never with
bash and never with `/Users/...` paths. Confirm the current contract from source or spec so the
prompt is accurate.

**Rule 4: Deliver the prompt to the user for the owning agent, and keep it in sync.**
Output the hand-off prompt (do not attempt the change yourself). If the owning agent proposes a
different contract, surface that back to the user rather than assuming.

**Hand-off prompt template:**
```
Project: <fap-service | fap-client | fap-infra>
Context: We are building <feature> in <this project>. <1–3 sentences end-to-end.>
Need: <exact contract/artifact requested>.
Relevant current state: <files/paths/endpoints that already exist>.
Fixed constraints: <hosts, ids, fingerprints, formats>.
Acceptance criteria: <how to verify>.
Please decide how best to implement this in your repository and reply with the resulting
contract/artifact and how to verify it.
```

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
**Base URL (prod):** `https://dev.fap.rs/api`
**Auth:** JWT stored in FlutterSecureStorage, attached via Dio interceptor as `Authorization: Bearer {token}`.
**Login Response:** `{ access_token: string, refresh_token: string }`

> **Note:** The endpoint/model tables below are a static *summary* and can drift from the
> backend. Always resolve the true contract from the live OpenAPI spec — see
> "REST API Spec — Source of Truth" below.

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

## Deep Links / App Links

Two token-driven email flows navigate from a Gmail link into the app. Both are parsed by
`lib/core/deep_links/deep_link_handler.dart` and **presented directly on the navigator**
(`lib/app/app.dart`) rather than through go_router, so the `StatefulShellRoute` home redirect
cannot hijack them while logged out.

**Registration confirmation** → `/confirm-registration/<token>`:

| URI | Purpose | Registered in |
|---|---|---|
| `fap://registration-confirm?token=…` | Manual `adb` testing / back-compat | `android/app/src/main/AndroidManifest.xml` (scheme `fap`); `ios/Runner/Info.plist` |
| `https://dev.fap.rs/registration-confirm?token=…` | Tappable link in the confirmation email (Gmail) | Android App Link intent-filter (`autoVerify`, host `dev.fap.rs`, path prefix `/registration-confirm`) + `fap-infra` `static/.well-known/assetlinks.json` (`handle_all_urls` + debug cert fingerprint) |

**Password reset** → `/reset-password/<token>`:

| URI | Purpose | Registered in |
|---|---|---|
| `fap://set-new-password?token=…` (`fap://reset-password?token=…` alias) | Manual `adb` testing / back-compat | `android/app/src/main/AndroidManifest.xml` (scheme `fap`); `ios/Runner/Info.plist` |
| `https://dev.fap.rs/set-new-password?token=…` | Tappable link in the reset email (Gmail) | Android App Link intent-filter (`autoVerify`, host `dev.fap.rs`, path prefix `/set-new-password`) + `fap-infra` `static/.well-known/assetlinks.json` |

`DeepLinkHandler` accepts `set-new-password` (the path the backend emits) and `reset-password`
(alias kept for manual testing); both map to the same route.

- The dev App Link / association domain is **`dev.fap.rs`**.
- Email links are produced by `fap-service`: the confirmation link from
  `email-configuration.reg-confirm-url` (env `REG_CONFIRM_URL`) and the reset link from its
  forgot-password URL (env `FORGOTTEN_PWD_URL`). Both now use the **HTTPS App Link** and are
  verified end-to-end: tapping the link in Gmail opens the app and navigates to the matching
  screen (registration confirmation / set-new-password).
- Changing the host requires lockstep updates across `fap-mobile` (manifest), `fap-infra`
  (assetlinks), and `fap-service` (email URLs).
- iOS Universal Links are **not configured yet** (no `apple-app-site-association`; no
  `applinks:` entitlement).

## REST API Spec — Source of Truth

**The backend OpenAPI spec is the single source of truth for endpoint contracts.
Never trust the static tables above or model field guesses over the live spec.**

**Rule 1: Prefer the live backend when it is running.**
Fetch the OpenAPI JSON directly (read-only) and inspect it:
```bash
# Health-check the backend first (expect 200):
curl -s -o /dev/null -w "%{http_code}" --max-time 10 http://localhost:8080/api/swagger-ui/index.html
# Fetch the spec JSON:
curl -s --max-time 15 http://localhost:8080/api/v3/api-docs -o /tmp/fap_openapi.json
# Inspect paths / operations / schemas with jq:
jq -r '.paths | keys[]' /tmp/fap_openapi.json
jq -r '.paths | to_entries[] | .key as $p | (.value | to_entries[] | select(.key!="parameters") |
  [$p,(.key|ascii_upcase),(.value.operationId // "-")] | @tsv)' /tmp/fap_openapi.json
jq -c '.components.schemas.<DtoName>' /tmp/fap_openapi.json
```
The Swagger UI is a JS app that cannot be clicked programmatically; its data comes
from the same `/v3/api-docs` JSON, so fetch that instead.

**Rule 2: If the backend is down, read fap-service source through the MCP filesystem server.**

The MCP filesystem server's root is `/workspace`. The backend lives at:

```
/workspace/FuelAutoPay/code/fap-service
```

Access it ONLY with the `filesystem_*` MCP tools — never with bash and never with
`/Users/...` paths. Bash runs on the host filesystem, where `/workspace` does not
exist; the MCP server cannot read host paths.

Tool mapping:
- `filesystem_list_allowed_directories` → confirm `/workspace` is exposed (do this first).
- `filesystem_directory_tree` / `filesystem_list_directory` → browse a directory.
- `filesystem_read_file` / `filesystem_read_multiple_files` → read files.
- `filesystem_search_files` → glob (e.g. `**/*Controller.java`, `**/*.yaml`).
- `filesystem_get_file_info` → metadata.

Navigation procedure:
1. Call `filesystem_list_allowed_directories`; it must include `/workspace`.
2. `filesystem_directory_tree` on `/workspace/FuelAutoPay/code/fap-service`.
3. Drill into `src/main/java/com/vincsoftware/fap/` for controllers/DTOs, or
   `doc/openapi/*.yaml` for the generated spec.

Key locations (under the root above):
- Generated spec: `doc/openapi/*.yaml`
- Controllers: `src/main/java/com/vincsoftware/fap/*/controller/*Controller.java`
- DTOs (contracts): `src/main/java/com/vincsoftware/fap/*/dto/*Dto.java`

If the `filesystem_*` tools are unavailable or `/workspace` is not exposed, STOP
and ask the user — do not silently fall back to bash on the local repo.

**Rule 3: Before defining or changing any endpoint / model, resolve the true contract.**
Confirm: HTTP method, path, path/query params, request body schema, response schema,
and auth requirement (bearer vs public). Record the DTO field names and constraints
exactly as declared (e.g. `maxLength`, `required`, enums).

**Rule 4: Keep `lib/core/network/api_constants.dart` in sync with the live spec.**
If the backend adds/renames/changes a path, update the constant(s) here first, then
any repository using them. If a UI feature needs an endpoint that does NOT exist in
the spec, flag it as a backend gap — do not invent a contract.

**Rule 5: Never hardcode endpoint paths or DTO shapes from memory/briefs.**
The static tables above and the project brief are summaries and can drift. When in
doubt, re-fetch the spec (Rule 1) or the backend source (Rule 2).

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
| Component-specific | `app_colors.dart` | `glassBorderLight`, `surfaceGlassLight`, `iconTileBackgroundLight` / `iconTileBackgroundDark` |

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

**Rule 0 (HARD BAN — no exceptions): No raw color literal may appear anywhere outside
`lib/core/theme/`.** The following are all forbidden in widgets, screens, and any other
file under `lib/`:

- `const Color(0xFF…)` / `Color(0x…)` / `const Color.fromARGB(…)` / `Color.fromRGBO(…)`
- `Colors.<name>` (e.g. `Colors.white`, `Colors.black`, `Colors.grey[800]`) — including
  `withValues(...)`/`withOpacity(...)` chains on them
- any inline `Color` built from raw hex/RGB

The **only** permitted exception is `Colors.transparent`, which represents the absence of
a color rather than a design token.

A color is allowed **only** if it resolves to one of:
1. a `theme.colorScheme.*` role (preferred — it adapts to light/dark automatically), or
2. a named constant exported from `lib/core/theme/app_colors.dart` (or another
   `lib/core/theme/` file).

`app_colors.dart` is the **only** file permitted to declare raw color values. If the value
you need already exists there, reuse it — do not re-declare it (see Color Reuse Rule).

**Anti-pattern (DO NOT):**
```dart
color: const Color(0xFF0B101A) // raw literal — must be `pageBaseDark`
```

**Correct pattern (DO):**
```dart
color: pageBaseDark
```

**Verification (must return zero matches before finishing any UI change):**
```bash
rg -n "Color\(0x|Color\.fromARGB|Color\.fromRGBO|Colors\." lib \
  --glob '!lib/core/theme/**' | grep -v 'Colors.transparent'
```

## Color Reuse Rule

**Rule 1: Always reuse existing named color constants first.**
Before introducing a new color, check whether an existing constant in `app_colors.dart`
(or the `ColorScheme` via `theme.colorScheme.*`) already represents the same hex value /
semantic intent. Prefer reusing it over duplicating. Do NOT add a new constant that is an
exact duplicate of an existing one.

**Anti-pattern (DO NOT — duplicates `vibrantCyan`):**
```dart
const verifiedFill = Color(0xFF00F5FF); // duplicate of vibrantCyan
```
**Correct pattern (DO):**
```dart
color: vibrantCyan
```

**Rule 2: Notify before adding a new color constant.**
If a genuinely new color is required (no existing constant matches), STOP and notify the
user: state the hex value, where it is used, and which token category it belongs to (e.g.
brand / surface / border / component-specific), and ask whether it should be added (and
whether a light + dark variant is needed). Do not add the constant silently. Only add it
to `app_colors.dart` after confirmation, and reference it from widgets — never embed the
raw value.

**Rule 3: Ensure every color used has a light and dark variant.**
Colors applied via `theme.colorScheme.*` adapt automatically. When using a named constant
that must look correct in both themes, either:
- use a cross-theme constant that is intentionally identical in both themes (e.g.
  `vibrantCyan`, `brandPrimary`), or
- branch on `theme.brightness` to provide a light and a dark value.
Never ship a color that only works in one theme without a counterpart for the other.

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

**Rule 3: Brand accents are theme-dependent — `brandPrimary` in light, `vibrantCyan` in dark.**
Brand accent text and icons (tagline, action links, inline call-to-action text, menu icon tiles)
use `brandPrimary` when `theme.brightness == Brightness.light` and `vibrantCyan` when dark.
Branch on `theme.brightness` (or a small local helper) instead of hardcoding `vibrantCyan` for
both themes. The `BrandTitle` wordmark is the exception: it keeps its cross-theme
`brandPrimary` stroke + `vibrantCyan` fill unless a screen overrides `fillColor`. Use
`theme.colorScheme.onSurfaceVariant` for secondary text that should simply adapt to the theme.

✅ **Theme-dependent brand accent:**
```dart
Color _accentColor(ThemeData theme) =>
    theme.brightness == Brightness.dark ? vibrantCyan : brandPrimary;

style: linkMedium.copyWith(color: _accentColor(theme))
```
✅ **Theme-adaptive secondary text:**
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
applied via `copyWith` — the theme accent (`brandPrimary` in light / `vibrantCyan` in dark,
see Rule 3) for action links, `theme.colorScheme.onSurfaceVariant` for footer links.

**Anti-pattern (DO NOT):**
```dart
style: theme.textTheme.bodySmall?.copyWith(
  color: brandPrimary,
  fontWeight: FontWeight.w600,
)
```

**Correct pattern (DO):**
```dart
style: linkMedium.copyWith(color: _accentColor(theme))
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
| Text | `TextButton` | transparent | theme accent (`brandPrimary` light / `vibrantCyan` dark) | "Forgot password?", "Sign up now" (inline links) |

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

## Icon Tile Convention

Menu and settings rows place the leading icon in a **40×40 rounded-square tile**
(`AppDimensions.radiusLg`). The tile fill and icon color are **theme-dependent**:

| Theme | Tile fill | Icon color |
|---|---|---|
| Light | `iconTileBackgroundLight` (a translucent `brandPrimary` tint) | `brandPrimary` |
| Dark | `iconTileBackgroundDark` (translucent slate-teal) | `vibrantCyan` |

- Reference implementations: `_MenuRow` in
  [`account_screen.dart`](lib/features/account/presentation/screens/account_screen.dart) and
  `_SettingsRow` in
  [`settings_screen.dart`](lib/features/settings/presentation/screens/settings_screen.dart).
- Use the shared constants from `app_colors.dart`; never inline the raw hex.
- **Destructive** rows (e.g. Delete Account) keep the error treatment: tile
  `theme.colorScheme.error.withValues(alpha: 0.1)`, icon `theme.colorScheme.error`.
- `accentCyanDark` (`#00DCE5`) is the dark-mode accent used for small affordances (e.g. the
  language picker chevron) where `brandPrimary` would have poor contrast.

## Verification
```bash
flutter analyze   # Zero errors
flutter test      # All passing
```
