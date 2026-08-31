# Decisions & Reminders

Recorded decisions for the passkeys/WebAuthn feature. Append new decisions as they are made;
never silently change a decided item — add a new entry superseding the old one.

## Decision log

| ID | Decision | Rationale | Date | Status |
|---|---|---|---|---|
| D1 | **Emulator-first development.** Build and validate locally on the Android emulator / iOS simulator with the existing `localhost` RP configuration. Production RP domain + assetlinks/AASA work is deferred to Phase 2 (backend G1). | Unblocks mobile work immediately; backend RP config is already contract-correct for dev. iOS passkeys will not work until a real HTTPS domain is configured (see D1 caveat below). | 2026-08-31 | ✅ Confirmed |
| D2 | **"Remove passkey" clears only the local flag.** Until backend G3 ships a user-scoped delete endpoint, removing a passkey in Settings only clears the client-side `passkeyEnabled` flag. The server credential remains (orphaned). Documented in the UI copy and revisited when G3 lands. | No backend delete endpoint exists yet; avoids inventing a contract (AGENTS.md Rule 5). | 2026-08-31 | ✅ Confirmed |
| D3 | **No real token-refresh for this feature.** The backend `refresh_token` is `"placeholder"` (G7). The app "re-open" biometric flow re-mints a fresh JWT by re-running passkey authentication. | Re-auth-on-open gives a fresh 15-min token naturally; a real refresh flow is a separate concern. | 2026-08-31 | ✅ Confirmed |
| D4 | **Full Phase 1 scope in one pass.** Implement all 11 Phase 1 steps (constants → models → repository → service → providers → Settings UI → Sign-in button → biometric re-open gate → ARB → platform config → verification). | User request; keeps the feature coherent and testable end-to-end. | 2026-08-31 | ✅ Confirmed |
| D5 | **Local `passkeyEnabled` flag is the source of truth until G2 ships.** `passkeyEnabledProvider` reads/writes `FlutterSecureStorage`. When backend G2 (`GET /v1/account/webauthn-credentials`) lands, switch to server truth. | Backend has no list-credentials endpoint (G2). | 2026-08-31 | ✅ Confirmed |

## Reminders (deferred / later)

- **Real token refresh (backend G7).** `WebAuthnAuthenticationService.java:175` and
  `WebAuthnAuthenticationSuccessHandler.java:63` return `refresh_token: "placeholder"`. When
  token refresh is implemented on the backend, the mobile client should store and use the real
  refresh token. Not in scope for this feature — revisit after Phase 2/3.
- **Production RP domain (backend G1).** Native passkeys require the RP to be an app-associated
  HTTPS domain. Android needs `assetlinks.json`; iOS needs the `webcredentials` entitlement +
  `apple-app-site-association`. Blocked on the team choosing the domain — see 02_backend_audit.md G1.
- **Server-side credential cleanup (backend G3).** After Phase 2-2, wire "Remove passkey" to the
  real `DELETE /v1/account/webauthn-credentials/{credentialId}` and stop orphaning server credentials.
- **Error-shape consistency (backend G6).** `/webauthn/**` errors are currently unstructured; once
  G6 ships, simplify the mobile `ApiException` parsing to a single `ProblemDetail` shape.

## Open questions

| # | Question | Owner | Status |
|---|---|---|---|
| Q1 | Which production domain becomes the WebAuthn RP id? (affects G1, assetlinks, AASA) | Backend/DevOps | ⏳ Open |
| Q2 | Is single-instance, in-memory options storage (G5) acceptable until production rollout? | Backend | ⏳ Open |
