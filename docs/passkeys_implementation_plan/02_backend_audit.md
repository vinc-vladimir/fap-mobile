# Backend WebAuthn Audit (`fap-service`)

Audited live source at `/Users/vvasic/Projects/FuelAutoPay/code/fap-service`
(Spring Boot 4.1.0, Spring Security **7.1.0**, `spring-security-webauthn:7.1.0` → webauthn4j-core `0.31.6`).
Filter-managed endpoint paths/JSON were verified from the Spring Security jar bytecode, not guessed.

> **Summary:** all four flows the mobile client needs (`register/options`, `register`,
> `authenticate/options`, `v1/auth/login/webauthn`) are **already contract-correct** and need
> **no backend change** for emulator-first development. Two blockers exist for real devices:
> **G1 (RP domain)** and the missing list/delete endpoints (**G2/G3**).

## 1. Confirmed current behavior

### Endpoint inventory

| Method | Path | Chain | Auth | Media |
|---|---|---|---|---|
| POST | `/webauthn/register/options` | AuthZ server chain (`/webauthn/**`) | Bearer JWT required | JSON out |
| POST | `/webauthn/register` | AuthZ server chain | Bearer JWT required | JSON in/out |
| DELETE | `/webauthn/register/{credentialId}` | AuthZ server chain | Bearer JWT required | built-in remove (undocumented) |
| POST | `/webauthn/authenticate/options` | AuthZ server chain | none (permitAll) | JSON out |
| POST | `/v1/auth/login/webauthn` | Resource server chain (`/v1/**`, stateless) | none (permitAll) | JSON in/out |

Key references:
- Chain matcher: `AuthorizationServerConfiguration.java:78` (`/oauth2/**`, `/login/**`, `/webauthn/**`).
- JWT resource server + permit list + `.webAuthn(...)` + CSRF: `AuthorizationServerConfiguration.java:91-106`.
- Custom login controller: `WebAuthnAuthenticationController.java:21-24`; permit: `ResourceServerConfiguration.java:43`.

### Confirmed JSON shapes (Spring Security 7.1.0)

- **`POST /webauthn/register/options`** → `PublicKeyCredentialCreationOptions`
  - `challenge`: random bytes, **base64url no padding**
  - `rp`: `{ id: "localhost", name: "Fuel Auto Pay" }` (hardcoded — see G1)
  - `user`: `{ id, name: <email>, displayName }` — `id` is a random/stable `Bytes`, **not** `AuthUser.id`; keyed by username=email
  - `pubKeyCredParams`: RS256/ES256/EdDSA (-257/-7/-8)
  - `authenticatorSelection`: `residentKey: "required"`, `userVerification: "preferred"`, `authenticatorAttachment` unset
  - `attestation: "none"`, `excludeCredentials`: existing creds of the user
- **`POST /webauthn/register`** request → `{ "publicKey": { "credential": <raw PublicKeyCredential>, "label": "<label>" } }` → `{ "success": true }`. The `options` field is **not** parsed (filter reloads options from the options repository).
- **`POST /webauthn/authenticate/options`** → `PublicKeyCredentialRequestOptions`: `challenge`, `rpId: "localhost"`, `userVerification: "preferred"`, and because the request is **unauthenticated**, `allowCredentials: []` (discoverable-credential mode — ideal for mobile sign-in).
- **`POST /v1/auth/login/webauthn`** request → `WebAuthnLoginRequest` (`id`, `rawId?`, `response{authenticatorData, clientDataJSON, signature, userHandle?}`, `clientExtensionResults?`, `authenticatorAttachment?`) → response `{ access_token, refresh_token }`.

### Registration flow

- Options tied to the authenticated user: `createPublicKeyCredentialCreationOptions` requires
  `Authentication.isAuthenticated()`; userEntity keyed by `getName()` = email (JWT subject).
- `InMemoryCredentialOptionsRepository.java` keys by security-context auth name for both
  `save` (`:28-33`) and `load` (`:38-52`) — resolves correctly across two stateless Bearer requests.
  **Caveat:** in-memory `ConcurrentHashMap` (`:19`) — lost on restart, single-instance only (G5).
- Persistence: `WebAuthnConfiguration.java:22-30` → `JdbcPublicKeyCredentialUserEntityRepository` +
  `JdbcUserCredentialRepository` (tables `user_entities`, `user_credentials`).
- Association to `AuthUser` is **indirect** (via `user_entities.name` = email), not a foreign key.

### Login/assertion flow

- `WebAuthnAuthenticationService.authenticate` (`:59-75`): rebuilds options from `clientDataJSON.challenge`
  (`:85-102`), builds credential (`:104-145`), `rpOperations.authenticate(...)` (`:64`), maps
  `userEntity.getName()` → `AuthUser` (`:147-153`), checks active (`:77-83`), mints JWT.
- **`userHandle` is optional** — omitted handles work (id/rawId are required). (`:115-123`)
- **base64url tolerant** — all decode via `Base64.getUrlDecoder()`; unpadded accepted.
- JWT: subject=email, `userId`, `authorities`, **900s TTL** (`:161-176`); `refresh_token` = `"placeholder"` (`:175`).
- **Bug G4:** `AuthenticatorAttachment.valueOf(attachment.toUpperCase())` (`:141`) — a
  cross-platform authenticator sends `"cross-platform"` → `valueOf` fails (enum is `CROSS_PLATFORM`)
  → 400. Only `"platform"` works today.

### RP/origin binding — the biggest blocker (G1)

- Effective RP for **all** operations comes from the `webAuthnRelyingPartyOperations` bean
  (`WebAuthnConfiguration.java:33-44`): `rp.id("localhost")`, `name("Fuel Auto Pay")`,
  `allowedOrigins = Set.of("http://localhost:4200")`.
- The `.webAuthn()` DSL values (`AuthorizationServerConfiguration.java:100-104`, from
  `AuthConfigProperties`) are **shadowed** by the existing bean — changing `application.yml`
  `auth-configuration.webauthn.*` does nothing today (G8).
- webauthn4j validates `clientDataJSON.origin` against the hardcoded origins on both registration
  and assertion. Native Android Credential Manager / iOS ASAuthorizationController bind the RP to
  an app-associated HTTPS domain and put the RP domain in `clientDataJSON.origin` → **never matches
  `http://localhost:4200`** → native passkeys cannot work until a real domain is configured.

### Error model

- `/v1/auth/login/webauthn` → RFC 7807 `ProblemDetail` (`InvalidCredentialsException` 400,
  `UserNotFoundException` 404, `UserNotRegisteredException` 406). Schema in `auth-api.yaml:522-542`.
- `/webauthn/**` filter errors are **not** ProblemDetail — unstructured body / bare status (G6).

### Tests & spec

- **No functional WebAuthn tests** (only `ProductionProfileIntegrationTest.java:63`, context load).
  All WebAuthn beans are `@Profile("!test")` so tests never exercise them.
- OpenAPI (`doc/openapi/auth-api.yaml`) documents only `POST /v1/auth/login/webauthn` +
  `WebAuthnLoginRequest` + `AuthResponse` + `ProblemDetail`. The four `/webauthn/**` endpoints and
  any credential-management endpoints are **not documented**.

## 2. Gap list

| # | Severity | Gap | Impact on mobile | Fix |
|---|---|---|---|---|
| G1 | **Blocker** | RP id/origins hardcoded `localhost` / `http://localhost:4200`; `AuthConfigProperties.webauthn` is dead config | Native passkeys never match origin; registration & login fail on real devices | Make the RP operations bean read rpId/rpName/allowedOrigins from config (per-profile); wire same into `.webAuthn()` DSL; pick prod domain |
| G2 | **High** | No endpoint to list current user's passkeys | Settings can't show "is passkey enabled" from server | `GET /v1/account/webauthn-credentials` (Bearer) → `[{ credentialId, label, createdAt, lastUsedAt, transports }]` |
| G3 | **High** | No user-scoped delete endpoint (only undocumented filter `DELETE /webauthn/register/{id}`) | "Remove passkey" can't remove the server credential | `DELETE /v1/account/webauthn-credentials/{credentialId}` (Bearer) → 204 / 404 |
| G4 | **High** | `authenticatorAttachment` mapping bug (`WebAuthnAuthenticationService.java:141`) | Cross-platform authenticators crash login | Map `cross-platform` → `CROSS_PLATFORM`, or drop the field (not needed for verify) |
| G5 | **Medium** | In-memory options repository (single instance, lost on restart, no TTL) | `register/options → register` state is non-distributed | DB/Redis-backed options repo with expiry (prod hardening, not a dev blocker) |
| G6 | **Medium** | `/webauthn/**` errors not RFC 7807 `ProblemDetail` | Mobile `ApiException` expects one documented shape | Filter-level failure handler emitting `ProblemDetail` for non-HTML requests |
| G7 | **Medium** | `refresh_token` is `"placeholder"` | App re-open re-mints via passkey auth — acceptable now | Real refresh flow on AS; mobile stores/uses it later (D3 reminder) |
| G8 | **Low** | Duplicate config source (bean vs DSL) | Config drift | Fold into G1 — single source of truth |
| G9 | **Low** | No tests + no OpenAPI for `/webauthn/**` / credential management | Contract unverified; mobile codegen incomplete | Integration tests for full native flow + document all endpoints |

**Coordinated contract note:** the four `/webauthn/**` flows + `POST /v1/auth/login/webauthn`
already match the mobile contract. Mobile can start immediately on emulator. Only mobile-affecting
backend change is **G1** (requires coordinated app association work). G2/G3 add endpoints mobile must mirror.

## 3. Recommended backend implementation order

1. G1 (RP/origin config) — blocker, needs domain decision + mobile assetlinks/AASA in lockstep
2. G4 (attachment mapping) — trivial, unblocks cross-platform authenticators
3. G6 (ProblemDetail on `/webauthn/**`) — one error shape for mobile
4. G2 + G3 (list/delete passkeys) — coordinate with mobile Settings
5. G9 (tests + OpenAPI)
6. G5 (persistent options store)
7. G7 (refresh token) — decision-gated

## 4. Key backend file references

- `auth/controller/WebAuthnAuthenticationController.java`
- `auth/service/WebAuthnAuthenticationService.java`
- `auth/dto/WebAuthnLoginRequest.java`, `auth/dto/AuthResponseDto.java`
- `auth/oauth2/AuthorizationServerConfiguration.java`, `WebAuthnConfiguration.java`,
  `WebAuthnAuthenticationSuccessHandler.java`, `InMemoryCredentialOptionsRepository.java`
- `auth/config/properties/AuthConfigProperties.java`
- `doc/openapi/auth-api.yaml`
