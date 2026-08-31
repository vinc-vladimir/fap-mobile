# Implementation Log — Passkeys / WebAuthn

Chronological log of the WebAuthn feature work in `fap-mobile`. Newest entry on top.
Format: `## YYYY-MM-DD` → bullets (what was done, files, verification, blockers/notes).

---

## 2026-08-31 — Documentation scaffold (Phase 0)

**What was done**
- Created `docs/passkeys_implementation_plan/` with six documents:
  - `README.md` — index + status dashboard (phase table + Phase 1/2/3 checklists).
  - `01_decisions.md` — recorded decisions D1–D5 + reminders (token refresh, G1/G3) + open questions.
  - `02_backend_audit.md` — backend WebAuthn audit: confirmed behavior + gap table G1–G9 +
    recommended backend order + file references.
  - `03_api_contracts.md` — exact endpoint contracts for the 5 flows + `passkeys` plugin mapping +
    planned G2/G3 endpoints.
  - `04_mobile_implementation_plan.md` — detailed Phase 1 steps P1-1…P1-11 with files & "done when".
  - `05_progress_log.md` — this log.

**Context / inputs**
- Backend audit performed by the backend AI agent against `fap-service` (Spring Boot 4.1.0,
  Spring Security 7.1.0) — verified filter endpoint paths/JSON from jar bytecode.
- Key conclusions: 4 flows already contract-correct (no backend change needed for emulator dev);
  G1 (RP domain) is the real-device blocker; G2/G3 (list/delete passkeys) are new endpoints needed.

**Decisions recorded**
- D1 emulator-first · D2 remove = local flag only until G3 · D3 no real token refresh (reminder
  noted) · D4 full Phase 1 scope · D5 local flag = source of truth until G2.

**Verification**
- Folder created, files written. No code changed yet.

**Next**
- Begin **P1-1** (constants + secure storage) — see README checklist / 04 plan.
