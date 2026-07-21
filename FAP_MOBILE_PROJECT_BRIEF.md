# Fuel Auto Pay (FAP) — Mobile Client Project Brief

> **Project:** fap-mobile (Flutter/Dart)
> **Package:** `com.vincsoftware.fap_mobile`
> **Location:** `/Users/vvasic/Projects/FuelAutoPay/code/fap-mobile`
> **Replaces:** `fap-client` (Angular 17 + Ionic 8 + Capacitor 6)
> **Platforms:** Android & iOS (Native)
> **AI Assistant:** DeepSeek V4 via OpenCode-Local

---

## 1. Platform Overview

### 1.1 What is Fuel Auto Pay?

Fuel Auto Pay (FAP) is an automated fuel payment system that streamlines the refueling experience for drivers. The platform leverages **Automatic Number Plate Recognition (ANPR)** technology to identify vehicles at participating gas stations and automatically process payments — eliminating the need for drivers to physically pay at the pump or inside the station.

### 1.2 The Automated Fueling Process

```
Vehicle arrives ──► ANPR Camera captures plate ──► Backend matches plate to account
       │                                                      │
       ▼                                                      ▼
  Driver refuels ◄──────────────────────────────── Payment method identified
       │
       ▼
  Fuel Management System records transaction ──► Automated payment
       │
       ▼
  Confirmation sent (push notification, digital receipt, email)
```

1. **Vehicle Identification** — The ANPR camera at the station captures and reads the license plate. Plate data is transmitted to the backend for processing.
2. **Data Processing** — The system matches the plate against registered user accounts, identifies the preferred payment method, and flags unregistered vehicles for alternative handling.
3. **Fuel Transaction** — The fuel management system records fuel quantity, price per liter, total amount, timestamp, and station location — all linked to the vehicle's ANPR record.
4. **Automated Payment** — The system initiates payment via the user's registered method.
5. **Transaction Confirmation** — Users receive instant confirmation via push notification, pump display, in-app digital receipt, and optional email.

### 1.3 Key Terminology

| Term | Definition |
|---|---|
| **ANPR** | Automatic Number Plate Recognition — camera-based plate reading technology |
| **FMS** | Fuel Management System — records transaction data at the pump |
| **Plate** | Vehicle registration/license plate — the key identifier in the system |
| **Payment Instrument** | A registered payment method (card, wallet) linked to the user's account |
| **Passkey** | WebAuthn-based biometric credential for passwordless authentication |
| **OTT** | One-Time Token — used for email confirmation and password reset |

---

## 2. Backend Architecture (`fap-service`)

### 2.1 Technology Stack

| Layer | Technology |
|---|---|
| Framework | Spring Boot 3 |
| Language | Java |
| Security | Spring Security 7 with OAuth2 Authorization Server |
| Database | PostgreSQL |
| ORM | JPA (Hibernate) |
| Auth Tokens | JWT (RSA-2048 signed, 15 min TTL) |
| Observability | Prometheus, Grafana, Tempo, OpenTelemetry |
| Containerization | Docker Compose |

### 2.2 Domain Model (JPA Entities)

```
AuthUser
├── id (String, PK)
├── email (String, unique, encrypted via StringConverter)
├── password (String, BCrypt hashed)
├── role (Enum: Role)
├── emailVerified (boolean)
├── created (LocalDateTime)
├── modified (LocalDateTime)
└── account (one-to-one → Account)

Account
├── id (String, PK)
├── firstName (String, encrypted)
├── lastName (String, encrypted)
├── phone (String, encrypted)
├── address (String, encrypted)
├── city (String)
├── zip (String)
├── country (String)
├── created (LocalDateTime)
├── modified (LocalDateTime)
├── authUser (one-to-one → AuthUser)
├── organization (many-to-one → Organization)
├── vehicleRegistrationPlates (one-to-many → VehicleRegistrationPlate)
└── paymentCards (one-to-many → PaymentCard)

Organization
├── id (String, PK)
├── name (String, encrypted)
├── crn (String, encrypted) — Company Registration Number
├── vat (String, encrypted)
├── phone (String, encrypted)
├── email (String, encrypted)
├── address (String, encrypted)
├── city (String)
├── zip (String)
├── country (String)
├── created (LocalDateTime)
├── modified (LocalDateTime)
└── accounts (one-to-many → Account)

VehicleRegistrationPlate
├── id (String, PK)
├── number (String, encrypted) — the plate number
├── registrationDate (LocalDate)
├── city (String)
├── country (String)
├── created (LocalDateTime)
├── modified (LocalDateTime)
└── accountId (String, FK → Account)

PaymentCard
├── id (String, PK)
├── paymentInstrumentId (String) — encrypted card token
├── isPrimary (Boolean)
├── created (LocalDateTime)
├── modified (LocalDateTime)
└── accountId (String, FK → Account)
```

### 2.3 Authentication Architecture

- **Password-based:** BCrypt hashing, JWT issued on successful login
- **Social Login:** Google & GitHub OAuth2 via Spring Security's OAuth2 client
- **WebAuthn/Passkeys:** Custom stateless endpoints using WebAuthn4J library
- **JWT Storage:** Returned as `{ access_token, refresh_token }`, stored client-side
- **Session:** Stateless — every request authenticated via Bearer JWT

### 2.4 REST API Endpoints

**Base URL (dev):** `http://localhost:8080/api`
**Base URL (prod):** `https://dev.fng.rs/api`

#### Auth Service

| # | Method | Path | Auth | Request Body | Response |
|---|---|---|---|---|---|
| 1 | POST | `/v1/auth/registration` | No | `{ email: string, password: string, role: "ADMIN" }` | any |
| 2 | POST | `/v1/auth/confirm/registration` | No | `{ token: string }` | any |
| 3 | POST | `/v1/auth/login` | No | `{ email: string, password: string }` | `LoginResponseModel` |
| 4 | POST | `/v1/auth/forgotten/password/email` | No | `{ email: string }` | any |
| 5 | POST | `/v1/auth/forgotten/password` | Token | `{ token: string, password: string, confirmedPassword: string, email?: string }` | any |
| 6 | POST | `/v1/auth/logout` | Yes | `{}` | any |
| 7 | POST | `/v1/auth/token/exchange` | Yes | `{ token: string }` | any |

#### WebAuthn Endpoints

| # | Method | Path | Auth | Request Body | Response |
|---|---|---|---|---|---|
| 8 | POST | `/webauthn/register/options` | Yes | `{}` | `WebauthnRegisterOptions` |
| 9 | POST | `/webauthn/register` | Yes | `{ publicKey: { credential: {...}, label: string } }` | `{ success: boolean }` |
| 10 | POST | `/webauthn/authenticate/options` | Yes | `{}` | `WebauthnAuthenticateOptions` |
| 11 | POST | `/v1/auth/login/webauthn` | Yes | `WebauthnAuthenticateRequest` | `LoginResponseModel` |

#### Account & Organization Endpoints

| # | Method | Path | Auth | Request Body | Response |
|---|---|---|---|---|---|
| 12 | GET | `/v1/account` | Yes | — | `AccountModel` |
| 13 | POST | `/v1/account` | Yes | `AccountModel` | `AccountModel` |
| 14 | PUT | `/v1/account/{accountId}` | Yes | `AccountModel` | `AccountModel` |
| 15 | GET | `/v1/account/{accountId}/organization/{orgId}` | Yes | — | `OrganizationModel` |
| 16 | POST | `/v1/account/{accountId}/organization` | Yes | `OrganizationModel` | `OrganizationModel` |
| 17 | PUT | `/v1/account/{accountId}/organization/{orgId}` | Yes | `OrganizationModel` | `OrganizationModel` |

#### OAuth2 Social Login (Browser Redirect)

| # | Method | Path | Description |
|---|---|---|---|
| 18 | GET | `/{base}/oauth2/authorization/google?redirect_uri={origin}/login` | Google OAuth2 |
| 19 | GET | `/{base}/oauth2/authorization/github?redirect_uri={origin}/login` | GitHub OAuth2 |

### 2.5 Data Transfer Objects (DTOs)

```typescript
// LoginResponseModel
{ access_token: string, refresh_token: string }

// AccountModel
{ firstName?: string, lastName?: string, phone?: string, address?: string,
  city?: string, zip?: string, country?: string, authUserId?: string,
  id?: string, organizationId?: string }

// OrganizationModel
{ id?: string, name?: string, crn?: string, vat?: string, phone?: string,
  email?: string, address?: string, city?: string, zip?: string,
  country?: string, accountId?: string }

// ErrorModel (all error responses)
{ timestamp: string, status: number, error: { message: string },
  trace: string, message: string, path: string }

// WebauthnRegisterOptions
{ challenge: string, rp: { id, name }, user: { id, name, displayName },
  pubKeyCredParams: [{ type, alg }], timeout?: number,
  excludeCredentials?: [{ id, type, transports? }],
  authenticatorSelection?: { authenticatorAttachment?, residentKey?,
    userVerification? }, attestation?: string }

// WebauthnRegisterRequest
{ publicKey: { credential: Record<string, unknown>, label: string } }

// WebauthnRegisterResponse
{ success: boolean }

// WebauthnAuthenticateOptions
{ challenge: string, timeout?: number, rpId?: string,
  allowCredentials?: [{ id, type, transports? }], userVerification?: string }

// WebauthnAuthenticateRequest
Record<string, unknown>  // The raw PublicKeyCredential JSON

// WebauthnAuthenticateResponse
LoginResponseModel  // { access_token, refresh_token }
```

### 2.6 WebAuthn Passkey Flow

**Registration (authenticated user in Settings):**
1. Client calls `POST /webauthn/register/options` → receives challenge + RP config
2. Client passes options to platform authenticator (Android Credential Manager / iOS ASAuthorizationController)
3. User verifies with biometric/PIN
4. Client calls `POST /webauthn/register` with the created credential
5. Backend stores credential

**Login (unauthenticated user on Sign In screen):**
1. Client calls `POST /webauthn/authenticate/options` → receives challenge
2. Client passes options to platform authenticator
3. User selects passkey and verifies with biometric/PIN
4. Client encodes assertion response (authenticatorData, clientDataJSON, signature, userHandle) as base64url
5. Client calls `POST /v1/auth/login/webauthn` with the assertion
6. Backend validates, returns `LoginResponseModel` with JWT

### 2.7 Observability

The backend is instrumented with:
- **Micrometer** for metrics (Prometheus at port 9090)
- **OpenTelemetry** for distributed tracing (Tempo at port 3200)
- **Grafana** dashboards for auth metrics (at port 3000)
- All services run in Docker Compose

---

## 3. Existing Client (`fap-client`) — Reference

### 3.1 Technology Stack

| Layer | Technology |
|---|---|
| Framework | Angular 17 (standalone components) |
| UI | Ionic 8 |
| Mobile | Capacitor 6 (Android only) |
| State | NgRx 17 (Store, Effects, Entity) |
| HTTP | Angular HttpClient |
| Styling | SCSS |
| OAuth | Google & GitHub |
| Testing | Jasmine + Karma |
| Linting | ESLint |

### 3.2 Current Features (MVP)

- User registration & email confirmation
- Login / logout with JWT (stored in sessionStorage)
- Social login via Google & GitHub
- Password reset flow
- Passkey (WebAuthn) registration & login
- Account profile management
- Organization/company profile management
- Route guards for authenticated pages

### 3.3 Missing Features (To Build in Flutter)

- License plate management (UI) — backend entity exists
- Payment method management (UI) — backend entity exists
- Home dashboard (FAP status, closest station, promotions, rewards)
- Gas station map with partner markers
- Transaction history with in-app digital receipts
- Push notification integration (FCM)
- Biometric app lock
- Offline support and caching

### 3.4 Route Structure

| Angular Path | Flutter Equivalent | Auth | Description |
|---|---|---|---|
| `/login` | `/login` | No | Email/password, social, passkey |
| `/registration` | `/register` | No | New user registration |
| `/registration-confirm` | `/register/confirm` | No | Email confirmation |
| `/forgot-password` | `/forgot-password` | No | Request reset email |
| `/set-new-password` | `/reset-password` | No | Set new password |
| `/home` | `/` or `/home` | Yes | Dashboard shell with navigation |
| `/home/account` | `/account` | Yes | Profile management |
| `/home/settings` | `/settings` | Yes | Passkey management |
| `/home/organization` | `/organization` | Yes | Company profile |

### 3.5 NgRx Store Structure (Reference for Provider Decomposition)

The Angular app uses 4 feature stores:

- **login** — State: `{ accessToken, error }`, Actions: Login, LoginSuccess, LoginFailed, Logout, LogoutSuccess, LogoutFailed, WebauthnLogin, WebauthnLoginSuccess, WebauthnLoginFailed, WebauthnLoginCancel
- **registration** — State: `{ error }`, Actions: Registration, RegistrationSuccess, RegistrationFailed, ConfirmRegistration, ConfirmRegistrationSuccess, ConfirmRegistrationFailed
- **account** — State: `{ account, organization, error }`, Actions: GetAccount, GetAccountSuccess, CreateAccount/UpdateAccount, GetOrganization/GetOrganizationSuccess, CreateOrganization/UpdateOrganization
- **forgot_password** — State: `{ error }`, Actions: SendEmail, SendEmailSuccess, SendEmailFailed, ChangePassword, ChangePasswordSuccess, ChangePasswordFailed

### 3.6 Service Layer (Reference for Dio Repository Implementation)

**AuthService** — REST calls to `/v1/auth/*`:
- `registration(email, password)` → POST `/v1/auth/registration`
- `confirmRegistration(token)` → POST `/v1/auth/confirm/registration`
- `login(email, password)` → POST `/v1/auth/login`
- `forgotPassword(email)` → POST `/v1/auth/forgotten/password/email`
- `changePassword(changePassword)` → POST `/v1/auth/forgotten/password`
- `logout()` → POST `/v1/auth/logout`
- `exchangeToken(token)` → POST `/v1/auth/token/exchange`

**WebauthnApiService** — REST calls to `/webauthn/*`:
- `getRegisterOptions()` → POST `/webauthn/register/options`
- `register(payload)` → POST `/webauthn/register`
- `getAuthenticateOptions()` → POST `/webauthn/authenticate/options`
- `login(payload)` → POST `/v1/auth/login/webauthn`

**AccountService** — REST calls to `/v1/account/*`:
- `getAccount()` → GET `/v1/account`
- `createAccount(account)` → POST `/v1/account`
- `updateAccount(account, accountId)` → PUT `/v1/account/{accountId}`
- `getOrganization(accountId, orgId)` → GET `/v1/account/{accountId}/organization/{orgId}`
- `createOrganization(accountId, org)` → POST `/v1/account/{accountId}/organization`
- `updateOrganization(accountId, org)` → PUT `/v1/account/{accountId}/organization/{orgId}`

**Auth Interceptor** — Reads JWT from sessionStorage (Flutter: FlutterSecureStorage), attaches as `Authorization: Bearer {token}`.

---

## 4. New Flutter Client (`fap-mobile`) — Architecture

### 4.1 Mandated Technology Stack

| Layer | Technology | Version | Why |
|---|---|---|---|
| Framework | Flutter | 3.44+ | Latest stable, Impeller renderer, Material 3 |
| Language | Dart | 3.12+ | Records, patterns, sealed classes, primary constructors |
| State Management | Riverpod | 3.x | Mainstream, compile-safe, no BuildContext dependency |
| Code Generation | riverpod_generator + freezed | latest | @riverpod annotation, immutable data classes |
| Routing | go_router | 17.x | Flutter-team maintained, ShellRoute, deep linking |
| HTTP Client | Dio | 5.x | Interceptors for JWT, retry, logging |
| Secure Storage | flutter_secure_storage | 10.x | Keychain (iOS) / AES-GCM (Android) |
| Passkeys | passkeys | 2.x | Cross-platform Credential Manager + ASAuthorizationController |
| Maps | google_maps_flutter | 2.x | Partner station map |
| Push Notifications | firebase_messaging | 16.x | FCM for fueling confirmations |
| Social Auth | flutter_appauth | 12.x | Google + GitHub OAuth2 via backend |
| JSON | json_serializable + json_annotation | latest | DTO serialization |
| DI | Riverpod (built-in) | — | Native provider-based DI |

### 4.2 Feature-First Project Structure

```
lib/
├── main.dart                          # App entry point, ProviderScope
├── app/
│   └── app.dart                       # MaterialApp.router with theme & router
├── core/
│   ├── network/
│   │   ├── api_client.dart            # Dio singleton with interceptors
│   │   ├── api_interceptors.dart      # Auth interceptor, logging, error
│   │   ├── api_constants.dart         # Base URLs, endpoint paths
│   │   └── api_exceptions.dart        # Custom exception types
│   ├── storage/
│   │   └── secure_storage.dart        # FlutterSecureStorage wrapper
│   ├── theme/
│   │   ├── app_colors.dart            # Color palette from Stitch design
│   │   ├── app_typography.dart        # Text styles from Stitch design
│   │   └── app_theme.dart             # Material 3 ThemeData
│   └── widgets/                       # Reusable UI components from Stitch
│       ├── fap_button.dart
│       ├── fap_input_field.dart
│       └── ...
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── models/
│   │   │       ├── login_response.dart
│   │   │       └── auth_models.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_providers.dart
│   │       └── screens/
│   │           ├── login_screen.dart
│   │           ├── register_screen.dart
│   │           ├── confirm_registration_screen.dart
│   │           ├── forgot_password_screen.dart
│   │           └── reset_password_screen.dart
│   ├── account/
│   │   ├── data/
│   │   │   ├── repositories/
│   │   │   │   └── account_repository.dart
│   │   │   └── models/
│   │   │       └── account_model.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── account_providers.dart
│   │       └── screens/
│   │           └── account_screen.dart
│   ├── organization/
│   │   ├── data/
│   │   │   ├── repositories/
│   │   │   │   └── organization_repository.dart
│   │   │   └── models/
│   │   │       └── organization_model.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── organization_providers.dart
│   │       └── screens/
│   │           └── organization_screen.dart
│   ├── vehicles/
│   │   ├── data/
│   │   │   ├── repositories/
│   │   │   │   └── vehicle_repository.dart
│   │   │   └── models/
│   │   │       └── vehicle_plate_model.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── vehicle_providers.dart
│   │       └── screens/
│   │           ├── vehicles_list_screen.dart
│   │           └── vehicle_form_screen.dart
│   ├── settings/
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── settings_providers.dart
│   │       └── screens/
│   │           └── settings_screen.dart
│   └── home/
│       └── presentation/
│           └── screens/
│               └── home_shell.dart     # Bottom navigation shell (Phase 2)
└── design/                             # Google Stitch export files
    ├── colors.md
    ├── typography.md
    └── screens/
        ├── login.md
        ├── register.md
        └── ...
```

### 4.3 Architecture Patterns

**Pattern: Feature-first with Repository + Riverpod Provider**

- **Data layer:** Repositories make HTTP calls via Dio. Models are `freezed` data classes. API calls return `AsyncValue<T>` via Riverpod.
- **Presentation layer:** Screens are stateless or stateful widgets. Logic is in Riverpod providers (StateNotifier or AsyncNotifier). Screens read providers via `ref.watch` and call methods via `ref.read`.
- **Routing:** go_router with `AuthGuard` redirect. `ShellRoute` for the authenticated shell with bottom navigation.
- **Auth flow:** JWT stored in `FlutterSecureStorage`. A global provider listens for auth state changes. Auth guard redirects to `/login` if no token.

**Key Riverpod Patterns:**
```dart
// Simple async provider for fetching data
@riverpod
Future<AccountModel> account(AccountRef ref) async {
  final repo = ref.watch(accountRepositoryProvider);
  return repo.getAccount();
}

// State notifier for mutations
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<void> build() => null;

  Future<void> login(String email, String password) async { ... }
  Future<void> logout() async { ... }
}
```

### 4.4 JWT Auth Interceptor (Dio)

```dart
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await _storage.delete(key: 'access_token');
      // Redirect to login
    }
    handler.next(err);
  }
}
```

---

## 5. MVP Implementation Plan (Phase 1)

### 5.1 Step 1: Project Scaffolding & Core Layer

**Files to create:**
- `pubspec.yaml` — add all dependencies
- `lib/main.dart` — ProviderScope wrapping App
- `lib/app/app.dart` — MaterialApp.router with theme and go_router
- `lib/core/network/api_constants.dart` — Base URLs, endpoint constants
- `lib/core/network/api_client.dart` — Dio instance with interceptors
- `lib/core/network/api_interceptors.dart` — AuthInterceptor, LoggingInterceptor, ErrorInterceptor
- `lib/core/storage/secure_storage.dart` — FlutterSecureStorage wrapper class

### 5.2 Step 2: Design System

**Apply Google Stitch exports to:**
- `lib/core/theme/app_colors.dart` — Color palette
- `lib/core/theme/app_typography.dart` — Text styles
- `lib/core/theme/app_theme.dart` — Material 3 ThemeData
- `lib/core/widgets/` — Reusable components (buttons, inputs, cards) matching Stitch specs

### 5.3 Step 3: Auth Feature

**Screens:**
- `LoginScreen` — Email/password form, Google/GitHub buttons, passkey button, "Forgot Password?" and "Sign Up" links
- `RegisterScreen` — Email, password, confirm password form
- `ConfirmRegistrationScreen` — Reads token from deep link, shows success/failure
- `ForgotPasswordScreen` — Email input to request reset
- `ResetPasswordScreen` — New password form with token from deep link

**Providers:**
- `authRepositoryProvider` — Dio-based repository
- `authStateProvider` — AsyncNotifier managing login/logout state
- `loginProvider` — Handles email/password login
- `webauthnLoginProvider` — Handles passkey login flow

**Endpoints used:** #1-7, #10-11 (auth + webauthn authenticate)

### 5.4 Step 4: Account Feature

**Screens:**
- `AccountScreen` — Form with firstName, lastName, phone, address, city, zip, country. Pre-filled if account exists. Save button.

**Providers:**
- `accountRepositoryProvider`
- `accountProvider` — Fetches account on init
- `accountFormProvider` — Manages save (create vs update)

**Endpoints used:** #12-14

### 5.5 Step 5: Organization Feature

**Screens:**
- `OrganizationScreen` — Form with name, crn, vat, phone, email, address, city, zip, country. Pre-filled if exists.

**Providers:**
- `organizationRepositoryProvider`
- `organizationProvider` — Fetches organization after account
- `organizationFormProvider` — Manages save (create vs update)

**Endpoints used:** #15-17

### 5.6 Step 6: License Plates Feature

**Screens:**
- `VehiclesListScreen` — List of registered plates with edit/delete
- `VehicleFormScreen` — Add/edit form (plate number, registration date, city, country)

**Note:** Backend `VehicleRegistrationPlate` entity exists. The REST endpoints for CRUD operations need to be confirmed/created if not already present.

**Providers:**
- `vehicleRepositoryProvider`
- `vehiclesListProvider` — Fetches list
- `vehicleFormProvider` — Manages add/edit

### 5.7 Step 7: Settings & Passkeys

**Screens:**
- `SettingsScreen` — "Add Passkey" button (shown if platform authenticator available), app info

**Providers:**
- `passkeyRegistrationProvider` — Handles WebAuthn registration flow:
  1. Call `POST /webauthn/register/options`
  2. Call platform passkey API (`passkeys` package)
  3. Call `POST /webauthn/register` with created credential

**Endpoints used:** #8-9

### 5.8 Step 8: go_router Configuration

```dart
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
                          state.matchedLocation.startsWith('/register') ||
                          state.matchedLocation.startsWith('/forgot-password');
      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/register/confirm', builder: (_, __) => const ConfirmRegistrationScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/reset-password', builder: (_, __) => const ResetPasswordScreen()),
      ShellRoute(
        builder: (_, __, child) => HomeShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/account', builder: (_, __) => const AccountScreen()),
          GoRoute(path: '/organization', builder: (_, __) => const OrganizationScreen()),
          GoRoute(path: '/vehicles', builder: (_, __) => const VehiclesListScreen()),
          GoRoute(path: '/vehicles/add', builder: (_, __) => const VehicleFormScreen()),
          GoRoute(path: '/vehicles/:id/edit', builder: (_, __) => const VehicleFormScreen()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        ],
      ),
    ],
  );
});
```

---

## 6. Future Phases (Phases 2-4)

### 6.1 Phase 2: Home Dashboard & Core Features

- Home dashboard with:
  - FAP account status (active/suspended)
  - Closest gas station display
  - Recent transactions summary
  - Promotions and rewards banner
- Bottom navigation shell:
  - Home, Stations, Transactions, Account
- Google Maps integration for partner station map

### 6.2 Phase 3: ANPR & Transaction Features

- Gas station map with:
  - Custom markers for partner stations
  - Station details (address, fuel types, prices)
  - Directions/navigation integration
- Transaction history list with filtering
- In-app digital receipts
- Push notification handling:
  - FCM token registration
  - Foreground/background notification display
  - Notification tap navigation to transaction detail

### 6.3 Phase 4: Polish & Production

- Payment method management (CRUD, set primary)
- Offline support with local caching
- Deep linking (password reset, email confirmation, transaction receipts)
- Biometric app lock (PIN/Face ID/Touch ID)
- Performance optimization (lazy loading, image caching, code splitting)
- Error monitoring and crash reporting
- App store submission preparation
- CI/CD pipeline setup

---

## 7. ANPR Hardware Reference

**Camera: Adaptive Recognition Einar (Gen 2)**

| Specification | Details |
|---|---|
| Models | Einar (IR), Einar W (white light), Einar Super T (IR + Telelens) |
| Resolution | 8MP (3840x2160) @ 30 FPS, Color CMOS sensor |
| ANPR Distance | 1.5-12 m (standard) / 9-80 m (Super T) |
| ANPR Speed | Up to 80 km/h (50 mph) |
| OCR Engine | CARMEN ANPR (ALPR) — on-board intelligence |
| On-Board | Direction detection, make & model recognition (11 categories), vehicle categorization |
| Communication | API, HTTP/HTTPS, MQTT, RTSP, ONVIF, FTP/SFTP, Modbus |
| Processing | 8-core ARM (2x2.2 GHz + 6x1.8 GHz) |
| Storage | 128 GB SD (expandable to 512 GB), up to 280,000 stored events |
| Environment | IP67, -40°C to +85°C |
| Power | PoE+, 5W typical / 22W max |
| Certifications | EU, CE, FCC, RoHS, NDAA compliant — Made in EU, 3-year warranty |
| Manufacturer | Adaptive Recognition |

---

## 8. Environment Configuration

```dart
class ApiConfig {
  static const String devBaseUrl = 'http://localhost:8080/api';
  static const String prodBaseUrl = 'https://dev.fng.rs/api';
  static const String serverApiUrl = kDebugMode ? devBaseUrl : prodBaseUrl;

  // OAuth2 redirect URI
  static const String redirectUri = 'com.vincsoftware.fap_mobile://oauth2redirect';

  // Endpoint paths
  static const String login = '/v1/auth/login';
  static const String register = '/v1/auth/registration';
  static const String confirmRegistration = '/v1/auth/confirm/registration';
  static const String forgotPasswordEmail = '/v1/auth/forgotten/password/email';
  static const String forgotPassword = '/v1/auth/forgotten/password';
  static const String logout = '/v1/auth/logout';
  static const String tokenExchange = '/v1/auth/token/exchange';
  static const String webauthnRegisterOptions = '/webauthn/register/options';
  static const String webauthnRegister = '/webauthn/register';
  static const String webauthnAuthOptions = '/webauthn/authenticate/options';
  static const String webauthnLogin = '/v1/auth/login/webauthn';
  static const String account = '/v1/account';
  static const String organization = '/v1/account/{accountId}/organization';

  // OAuth2 URLs
  static String googleAuthUrl(String origin) =>
      '$serverApiUrl/oauth2/authorization/google?redirect_uri=$origin/login';
  static String githubAuthUrl(String origin) =>
      '$serverApiUrl/oauth2/authorization/github?redirect_uri=$origin/login';
}
```

---

## 9. Development Commands

```bash
cd /Users/vvasic/Projects/FuelAutoPay/code/fap-mobile

# Get dependencies
flutter pub get

# Run code generation (freezed, json_serializable, riverpod_generator)
dart run build_runner build --delete-conflicting-outputs

# Analyze code
flutter analyze

# Run tests
flutter test

# Build for Android
flutter build apk --debug
flutter build apk --release

# Build for iOS
flutter build ios --debug --no-codesign
flutter build ios --release --no-codesign
```

---

## 10. Design Integration

The new UI design is exported from **Google Stitch** as markdown files. These files define:

- **Color palette** (`design/colors.md`) — hex values for primitives, surfaces, semantic colors
- **Typography** (`design/typography.md`) — font family, size, weight, line height per text style
- **Component specs** — buttons, input fields, cards, dialogs, navigation bars
- **Screen layouts** (`design/screens/*.md`) — per-screen layout specs

**Integration process:**
1. Read the Stitch export markdown files
2. Translate color tokens to `app_colors.dart` as `Color` constants
3. Translate typography tokens to `app_typography.dart` as `TextStyle` constants
4. Combine into `app_theme.dart` as a Material 3 `ThemeData`
5. Build reusable widgets in `core/widgets/` matching Stitch component specs
6. Apply theme and widgets to each screen

---

## 11. References

| Resource | Path / ID |
|---|---|
| Existing fap-client (Angular) | `/Users/vvasic/Projects/FuelAutoPay/code/fap-client` |
| Backend fap-service (Spring Boot) | `/Users/vvasic/Projects/FuelAutoPay/code/fap-service` |
| j-rag knowledge base (all sources) | Project ID: `fap` |
| OpenCode config | `opencode.jsonc` in project root |
| Agent instructions | `AGENTS.md` in project root |
| j-rag usage guide | `J_RAG_REFERENCE.md` in project root |
