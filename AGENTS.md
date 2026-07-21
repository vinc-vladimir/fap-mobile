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

## Verification
```bash
flutter analyze   # Zero errors
flutter test      # All passing
```
