# API Contracts — WebAuthn (source of truth)

Exact request/response contracts for the endpoints used by the passkey feature. Verified against
the backend audit (02_backend_audit.md) and the `passkeys` Flutter plugin (`2.22.0`).
Base URL: `http://10.0.2.2:8080/api` (Android emulator) / `http://localhost:8080/api` (iOS sim) in debug.

## 1. Registration options

```
POST {base}/webauthn/register/options      Bearer JWT required
Request body: {}  (empty object)
```

Response — `PublicKeyCredentialCreationOptions` (JSON):

```json
{
  "challenge": "<base64url-no-padding>",
  "rp": { "id": "localhost", "name": "Fuel Auto Pay" },
  "user": {
    "id": "<base64url-no-padding>",
    "name": "<email>",
    "displayName": "<displayName>"
  },
  "pubKeyCredParams": [
    { "type": "public-key", "alg": -257 },
    { "type": "public-key", "alg": -7 },
    { "type": "public-key", "alg": -8 }
  ],
  "authenticatorSelection": {
    "residentKey": "required",
    "userVerification": "preferred"
  },
  "attestation": "none",
  "excludeCredentials": []
}
```

- `timeout` may be present. All binary values are **base64url without padding**.
- Fields are consumed by the `passkeys` plugin via `RegisterRequestType.fromJsonString(...)` —
  pass the raw response body string unchanged.

## 2. Registration finish

```
POST {base}/webauthn/register      Bearer JWT required
```

Request body:

```json
{
  "publicKey": {
    "credential": { "<raw PublicKeyCredential from RegisterResponseType.toJsonString()>" },
    "label": "<device label, e.g. 'iPhone 15' or 'Pixel 8'>"
  }
}
```

- `credential` is the decoded map of `RegisterResponseType.toJsonString()` output
  (`id`, `rawId`, `response{clientDataJSON, attestationObject}`, `type`, `clientExtensionResults`).
- The `options` field is **not** parsed by the backend — do not send it.

Response:

```json
{ "success": true }
```

## 3. Authentication options

```
POST {base}/webauthn/authenticate/options      no auth
Request body: {}  (empty object)
```

Response — `PublicKeyCredentialRequestOptions` (JSON):

```json
{
  "challenge": "<base64url-no-padding>",
  "rpId": "localhost",
  "userVerification": "preferred",
  "timeout": 300000,
  "allowCredentials": []
}
```

- `allowCredentials: []` ⇒ discoverable-credential mode (correct for mobile passkey sign-in).
- Consumed by the `passkeys` plugin via `AuthenticateRequestType.fromJsonString(...)` — pass the
  raw response body string unchanged.

## 4. Passkey login (issues JWT)

```
POST {base}/v1/auth/login/webauthn      no auth
```

Request body — the decoded map of `AuthenticateResponseType.toJsonString()` output:

```json
{
  "id": "<credential id, base64url>",
  "rawId": "<base64url>",
  "response": {
    "authenticatorData": "<base64url>",
    "clientDataJSON": "<base64url>",
    "signature": "<base64url>",
    "userHandle": "<base64url>"   // optional — may be omitted
  },
  "type": "public-key",
  "clientExtensionResults": {},
  "authenticatorAttachment": "platform"
}
```

- Backend requires `id`/`rawId` and the three `response` fields; `userHandle` and
  `authenticatorAttachment` are optional. `authenticatorAttachment` must be `"platform"` today
  (backend G4 breaks on `"cross-platform"`).

Response:

```json
{
  "access_token": "<JWT>",
  "refresh_token": "placeholder"
}
```

- JWT claims: `sub` = email, `userId`, `authorities`; TTL 900 s.
- `refresh_token` is a placeholder (G7) — store it but do not rely on it.

## 5. Error model

- `/v1/**` (incl. `login/webauthn`) → RFC 7807 `ProblemDetail`:

```json
{
  "type": "urn:...#<endpoint>",
  "title": "...",
  "status": 400,
  "detail": "...",
  "instance": "...",
  "errorCategory": "...",
  "timestamp": "2026-08-31T00:00:00Z"
}
```

- `/webauthn/**` → currently unstructured (bare status / empty body) until backend G6. The mobile
  `ApiException` parser must tolerate both shapes.

## 6. Mobile `passkeys` plugin mapping

| Plugin call | Input | Output | Backend step |
|---|---|---|---|
| `PasskeyAuthenticator().register(request)` | `RegisterRequestType.fromJsonString(creationOptionsJson)` | `RegisterResponseType` → `.toJsonString()` | wrap in `{ publicKey: { credential: <map>, label } }` → `POST /webauthn/register` |
| `PasskeyAuthenticator().authenticate(request)` | `AuthenticateRequestType.fromJsonString(assertionOptionsJson)` | `AuthenticateResponseType` → `.toJsonString()` | decode map → `POST /v1/auth/login/webauthn` |
| `PasskeyAuthenticator().getAvailability()` | — | platform support flags | gate UI (hide passkey buttons when unsupported) |

Typed exceptions to handle: `PasskeyAuthCancelledException`, `NoCredentialsAvailableException`,
`MissingGoogleSignInException` (Android), `DomainNotAssociatedException`,
`NoCreateOptionException`, `MalformedBase64UrlChallenge`.

## 7. Planned additions (Phase 2, pending backend)

- `GET {base}/v1/account/webauthn-credentials` (Bearer) → `[{ credentialId, label, createdAt, lastUsedAt, transports }]`
- `DELETE {base}/v1/account/webauthn-credentials/{credentialId}` (Bearer) → `204` / `404`

These will replace the local `passkeyEnabled` flag as the source of truth (D5) and enable a real
"Remove passkey". Contracts to be confirmed from the live backend spec when shipped.
