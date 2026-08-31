# Passkeys / WebAuthn — Implementation Plan (fap-mobile ↔ fap-service)

> **Status dashboard** for the WebAuthn (passkey / biometric) feature in the Fuel Auto Pay
> Flutter mobile client. Update this file whenever a phase/step changes state.

## Context

Enable WebAuthn in `fap-mobile` so a user can:

1. Register a passkey (biometric — Face ID / fingerprint) from the **Settings** screen.
2. Sign in with a passkey (biometric) from the **Sign-in** screen.
3. On **app open**, if a passkey is registered, prompt for the biometric scan before showing
   the home screen (identity confirmation gate).

Backend (`fap-service`) exposes the WebAuthn endpoints via Spring Security filter-managed
`/webauthn/**` routes + a custom `POST /v1/auth/login/webauthn`. The backend audit (see
[02_backend_audit.md](./02_backend_audit.md)) confirmed all four flows already match the
mobile contract — **no backend change is needed for emulator-first development**.

## Phase summary

| Phase | Description | Status | Key deliverable |
|---|---|---|---|
| 0 | Docs & decisions | ✅ Done | This plan + [01_decisions.md](./01_decisions.md) |
| 1 | Mobile implementation (emulator-first, no backend dependency) | ⏳ Pending | Full passkey feature in `fap-mobile` |
| 2 | Backend-coordinated (G1 RP domain, G2/G3 list/delete) | ⏳ Pending | Real-device passkeys + server-truth passkey state |
| 3 | Backend hardening (G4, G6, G9, G5, G7) | ⏳ Pending | Prod-safe WebAuthn + docs/tests |

## Phase 1 checklist (fap-mobile)

- [ ] **P1-1** Core constants & storage — `api_constants.dart`, `SecureStorage` passkey flag
- [ ] **P1-2** Models — `passkey_models.dart` (freezed) + codegen
- [ ] **P1-3** REST repository — `passkey_repository.dart`
- [ ] **P1-4** Platform service — `passkey_service.dart` (`PasskeyAuthenticator` wrapper)
- [ ] **P1-5** Providers — `passkey_providers.dart` (register, login, enabled flag)
- [ ] **P1-6** Settings screen — "Add / Remove passkey" rows (local flag)
- [ ] **P1-7** Sign-in screen — wire biometric button to passkey login
- [ ] **P1-8** Biometric re-open gate — `AuthState` cold-start + `BiometricGateScreen` + route
- [ ] **P1-9** ARB strings (en + sr) + regen
- [ ] **P1-10** Platform config — Android assetlinks note, iOS `webcredentials` placeholder
- [ ] **P1-11** Verify — `build_runner` → `flutter analyze` → `flutter test` → manual emulator test

Detailed steps & "definition of done": [04_mobile_implementation_plan.md](./04_mobile_implementation_plan.md)

## Phase 2 checklist (backend-coordinated)

- [ ] **P2-1** G1 — production RP domain chosen; backend config + mobile assetlinks/AASA lockstep
- [ ] **P2-2** G2/G3 — backend ships `GET/DELETE /v1/account/webauthn-credentials`; switch `passkeyEnabledProvider` from local flag → server truth; real "Remove passkey"

## Phase 3 checklist (backend hardening — tracked, not mobile-blocking)

- [ ] **P3-1** G4 — `authenticatorAttachment` mapping bug fix (backend)
- [ ] **P3-2** G6 — `ProblemDetail` errors on `/webauthn/**` (backend)
- [ ] **P3-3** G9 — backend integration tests + OpenAPI docs for `/webauthn/**`
- [ ] **P3-4** G5 — persistent (non-in-memory) credential-options repository (backend)
- [ ] **P3-5** G7 — real `refresh_token` (backend) — **decision reminder, see 01_decisions.md D3**

## How to use this plan

1. Open this README at the start of every working session.
2. Check the phase summary + checklist to find the current step.
3. Work the step; update the checkbox and the phase table.
4. Append a dated entry to [05_progress_log.md](./05_progress_log.md) (what was done, files, verification, blockers).
5. Record any new decisions in [01_decisions.md](./01_decisions.md).

## Documents

| File | Purpose |
|---|---|
| [01_decisions.md](./01_decisions.md) | Recorded decisions & open reminders |
| [02_backend_audit.md](./02_backend_audit.md) | Backend WebAuthn audit — confirmed behavior + gaps G1–G9 |
| [03_api_contracts.md](./03_api_contracts.md) | Exact endpoint contracts (source of truth) |
| [04_mobile_implementation_plan.md](./04_mobile_implementation_plan.md) | Detailed phased implementation plan |
| [05_progress_log.md](./05_progress_log.md) | Chronological implementation log |
