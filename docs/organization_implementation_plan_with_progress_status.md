# Organization Feature — Implementation Plan & Progress Status (fap-mobile)

> **Status dashboard** for the Organization (B2B fleet) feature in the Fuel Auto Pay
> Flutter mobile client. Update the phase table, checklists, and progress log whenever a
> step changes state.

## Context

A registered user always has an account, but only **optionally** belongs to an
organization. The account that creates an organization becomes its `ORG_OWNER`; invited
users join as `ORG_MEMBER`. There is exactly one owner per organization and a person may
belong to **at most one** organization.

This plan delivers the organization area in `fap-mobile`, staged so each phase is
independently shippable. Phase 1 (profile CRUD + membership + Account entry) is the only
phase implemented so far.

**Out of scope for Phase 1:** members management, fleet vehicles, fleet payment cards,
invitations + invitee deep-link flow, `fap-infra` assetlinks.

## Backend contract (source of truth)

Resolved from the live OpenAPI spec (`http://localhost:8080/api/v3/api-docs`) and
`fap-service/doc/openapi/organization-api.yaml`.

| Endpoint | Method | Auth / role | Phase |
|---|---|---|---|
| `/v1/organizations/me` | GET | member | 1 |
| `/v1/organizations` | POST | any (caller becomes `ORG_OWNER`) | 1 |
| `/v1/organizations/{id}` | GET | member | 1 |
| `/v1/organizations/{id}` | PUT | `ORG_OWNER` | 1 |
| `/v1/organizations/{id}/deactivate` | POST | `ORG_OWNER` | 1 |
| `/v1/organizations/{id}/members` | GET | member | 2 |
| `/v1/organizations/{id}/members/{memberId}` | DELETE | `ORG_OWNER` | 2 |
| `/v1/organizations/{id}/transfer-ownership` | POST | `ORG_OWNER` | 2 |
| `/v1/organizations/{id}/vehicles` | GET/POST | member / `ORG_OWNER` | 3 |
| `/v1/organizations/{id}/payment-cards` | GET/POST | `ORG_OWNER` | 4 |
| `/v1/organizations/{id}/payment-cards/{cardId}` | PUT/DELETE | `ORG_OWNER` | 4 |
| `/v1/organizations/{id}/invitations` | GET/POST | `ORG_OWNER` | 5 |
| `/v1/organizations/{id}/invitations/{invitationId}` | DELETE | `ORG_OWNER` | 5 |
| `/v1/invitations/{token}` | GET | **public** | 5 |
| `/v1/invitations/{token}/accept` | POST | authenticated invitee | 5 |

**Membership discovery.** `GET /v1/organizations/me` returns
`OrganizationMembershipDto { organizationId: string|null, role: "ORG_OWNER"|"ORG_MEMBER"|null }`.
Both fields are `null` when the caller has no organization (still HTTP 200). The app then
fetches the full profile with `GET /v1/organizations/{organizationId}` (two-step lookup).

**Writable fields.** Create/update send only `name, crn, vat, phone, email, address, city,
zip, country`; `id`, `active`, `createdAt` are server-managed and ignored if sent.

**Errors.** RFC 7807 `ProblemDetail` (`detail` / `title`), already mapped by
`ApiException.fromDio`.

## Phase summary

| Phase | Description | Status | Key deliverable |
|---|---|---|---|
| 1 | Org profile CRUD (create/read/update/deactivate) + membership + Account entry + routing + l10n + tests | ✅ Done — verified on device | Organization area reachable from Account |
| 2 | Members & ownership (list, remove, transfer) — owner-gated | ⏳ Pending | Member management screen |
| 3 | Fleet vehicles (list, add) | ⏳ Pending | Fleet vehicles screen |
| 4 | Fleet payment cards (list/add/edit/delete/primary; masked display) | ⏳ Pending | Fleet cards screen |
| 5 | Invitations (invite/list/revoke) + invitee deep-link & registration flow | ⏳ Pending | End-to-end invite flow |
| 6 | `fap-infra` hand-off: `assetlinks.json` for `/org-invitation` | ⏳ Pending | App Link verified (with Phase 5) |

## Phase 1 checklist (fap-mobile)

- [x] **P1-0** Tracking doc — this file
- [x] **P1-1** Network constants — `lib/core/network/api_constants.dart`
- [x] **P1-2** Models (freezed) — `organization_model.dart`, `organization_request.dart`, `organization_membership_model.dart`, `organization_role.dart` + codegen
- [x] **P1-3** Repository — `lib/features/organization/data/repositories/organization_repository.dart`
- [x] **P1-4** Providers — `lib/features/organization/presentation/providers/organization_providers.dart` + login/logout invalidation
- [x] **P1-5** Screens — `organization_screen.dart`, `organization_form_screen.dart`; wire Account menu row
- [x] **P1-6** Routing — nested `/account/organization`, `/create`, `/edit` in `app_router.dart`
- [x] **P1-7** ARB strings (en + sr) + regen
- [x] **P1-8** Tests — repository (Dio fake adapter) + widget (empty/populated/role gating)
- [x] **P1-9** Verify — `build_runner` ✅, `flutter analyze` ✅ (0 issues), raw-color scan ✅, `flutter test` ✅ (11/11 passing)

### Phase 1 definition of done

An authenticated user can create, view, edit, and deactivate their organization from the
Account tab; membership resolves correctly (no org / owner / member); owner-only actions
are hidden for members; `flutter analyze` and `flutter test` are green; no raw color
literals outside `lib/core/theme/`.

**Status: met.** Confirmed by the user on device — all Phase 1 scope works successfully.

## Phases 2–5 outline (stubbed)

- **Phase 2 — Members & ownership.** `getMembers`, `removeMember`, `transferOwnership`;
  members list screen (member-visible), remove + transfer owner-gated with confirmation.
- **Phase 3 — Fleet vehicles.** `getVehicles`, `addVehicle`; list (member), add (owner).
- **Phase 4 — Fleet payment cards.** `getCards`, `addCard`, `updateCard`, `deleteCard`;
  masked display (issuer + primary + last-4), primary semantics.
- **Phase 5 — Invitations.** `inviteMember`, `getInvitations`, `revokeInvitation`, public
  `getInvitationDetails`, `acceptInvitation`; `org-invitation` deep link; invited sign-up
  with `invitationToken` (auth registration change). Requires `fap-infra` assetlinks
  hand-off.

## Decisions & open questions

| # | Decision / question | Status |
|---|---|---|
| D1 | Membership resolved via `GET /v1/organizations/me` then `GET /v1/organizations/{id}` (two-step) | Accepted |
| D2 | Phase 1 scope = profile CRUD + membership + entry only | Accepted |
| D3 | Organization deactivate is part of Phase 1 | Accepted |
| D4 | Entry point: Account "Organization" menu row → `/account/organization` | Accepted |
| D5 | Screens match the existing account / personal-details patterns (no Stitch export) | Accepted |
| D6 | Fleet cards display: issuer + primary + last-4 only (Phase 4) | Accepted |
| D7 | Stale `AccountModel.organizationId` left untouched for now | Accepted |

## Progress log

> Newest first. Each entry: date — step — what was done — files — verification — blockers.

- **2026-09-20 — Phase 1 accepted on device ✅.**
  - **What:** User tested Phase 1 end-to-end on device; all scoped behaviour works
    (create / view / edit / deactivate, membership resolution, owner vs member gating).
  - **Verification:** manual device test — passed. Automated: `flutter test` 11/11,
    `flutter analyze` 0 issues.
  - **Blockers:** none. Phase 1 closed; Phase 2 may proceed.

- **2026-09-20 — Phase 1 verified ✅.**
  - **What:** Xcode license accepted by the user; `xcrun`/`clang` now work.
  - **Verification:** `flutter test` ✅ — 11/11 passing
    (`test/organization_repository_test.dart` 7, `test/organization_screen_test.dart` 3,
    existing `test/widget_test.dart` 1). `flutter analyze` ✅ 0 issues.
  - **Blockers:** none.

- **2026-09-20 — Phase 1 implemented (code complete).**
  - **What:** Org profile CRUD + membership discovery + Account entry.
    - Constants: added `organizations`, `organizationMe`, `organization(id)`,
      `organizationDeactivate(id)`; removed the stale
      `/v1/account/{accountId}/organization` path.
    - Models: `OrganizationModel`, `OrganizationRequest`, `OrganizationMembershipModel`,
      `OrganizationRole` (freezed/json_serializable).
    - Repository: `OrganizationRepository` (`getMembership`, `createOrganization`,
      `getOrganization`, `updateOrganization`, `deactivateOrganization`).
    - Providers: `organizationRepositoryProvider`, `organizationMembershipProvider`,
      `organizationProvider` (two-step: `me` → `{id}`), `OrganizationFormController`
      (`create` / `updateOrganization`), `OrganizationLifecycleController` (`deactivate`);
      membership invalidated on login/logout in `auth_providers.dart`.
    - Screens: `OrganizationScreen` (empty / profile / role-gated owner actions) and
      `OrganizationFormScreen` (create/edit); Account "Organization" row now navigates.
    - Routing: nested `/account/organization`, `/create`, `/edit`.
    - l10n: ~24 new keys in `app_en.arb` + `app_sr.arb`.
    - Tests: `test/organization_repository_test.dart`, `test/organization_screen_test.dart`.
  - **Verification:** `dart run build_runner build` ✅ · `flutter analyze` ✅ 0 issues ·
    raw-color scan ✅ (only permitted `Colors.transparent` outside `lib/core/theme/`).
  - **Blocker:** `flutter test` cannot run on this host — `clang` fails with
    *"You have not agreed to the Xcode license agreements."* (affects the pre-existing
    `test/widget_test.dart` too, so it is environmental, not code). Fix:
    `sudo xcodebuild -license accept` (or `sudo xcodebuild -runFirstLaunch`), then
    `flutter test`.

## How to use this plan

1. Open this file at the start of every working session.
2. Find the current step in the phase summary + checklist.
3. Work the step; tick the checkbox and update the phase table status.
4. Append a dated entry to the progress log (what was done, files, verification, blockers).
5. Record any new decisions in the decisions table.
