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
| 2 | Members & ownership (list, remove, transfer) — owner-gated | ✅ Done — verified on device | Member management screen |
| 3 | Fleet vehicles (list, add) | ⏳ Pending | Fleet vehicles screen |
| 4 | Fleet payment cards (list/add/edit/delete/primary; masked display) | ⏳ Pending | Fleet cards screen |
| 5 | Invitations (invite/list/revoke) + invitee deep-link & registration flow | ✅ Done — verified on device | End-to-end invite flow |
| 6 | `fap-infra` hand-off: `assetlinks.json` for `/org-invitation` | ✅ Closed — not required (`handle_all_urls` already covers all paths) | — |

## Phase 1 checklist (fap-mobile)

- [x] **P1-0** Tracking doc — this file
- [x] **P1-1** Network constants — `lib/core/network/api_constants.dart`
- [x] **P1-2** Models (freezed) — `organization_model.dart`, `organization_request.dart`, `organization_membership_model.dart`, `organization_role.dart` + codegen
- [x] **P1-3** Repository — `lib/features/organization/data/repositories/organization_repository.dart`
- [x] **P1-4** Providers — `lib/features/organization/presentation/providers/organization_providers.dart` + login/logout invalidation
- [x] **P1-5** Screens — `organization_screen.dart`, `organization_form_screen.dart`; wire Account menu row
- [x] **P1-6** Routing — nested `/account/organization`, `/create`, `/edit` in `app_router.dart`
- [x] **P1-7** ARB strings (en + sr) + regen
- [x] **P1-8** Tests — repository (Dio fake adapter) + widget (empty/populated/role gating/error+retry) + form (validation/prefill)
- [x] **P1-9** Verify — `build_runner` ✅, `flutter analyze` ✅ (0 issues), raw-color scan ✅, `flutter test` ✅ (16/16 passing)
- [x] **P1-10** Docs — README "Organization (Phase 1)" + "Testing" sections; `docs/lessons_learned/08-organization-phase1.md`

### Phase 1 definition of done

An authenticated user can create, view, edit, and deactivate their organization from the
Account tab; membership resolves correctly (no org / owner / member); owner-only actions
are hidden for members; `flutter analyze` and `flutter test` are green; no raw color
literals outside `lib/core/theme/`.

**Status: met.** Confirmed by the user on device — all Phase 1 scope works successfully.

## Phases 2–5 outline (stubbed)

- **Phase 2 — Members & ownership.** ✅ Done — see checklist below.
- **Phase 3 — Fleet vehicles.** `getVehicles`, `addVehicle`; list (member), add (owner).
- **Phase 4 — Fleet payment cards.** `getCards`, `addCard`, `updateCard`, `deleteCard`;
  masked display (issuer + primary + last-4), primary semantics.
- **Phase 5 — Invitations.** ✅ Done — see checklist below.

## Phase 5 checklist (fap-mobile)

- [x] **P5-1** Constants — `organizationInvitations`, `organizationInvitation`, `invitationDetails`, `invitationAccept`
- [x] **P5-2** Models — `OrganizationInvitationModel`, `OrganizationInvitationStatus`, `CreateInvitationRequest`, `OrganizationInvitationDetailsModel`, `InvitedRegistrationRequest`
- [x] **P5-3** Repository — `inviteMember`, `getInvitations`, `revokeInvitation`, `getInvitationDetails`, `acceptInvitation`; `AuthRepository.registerInvited`
- [x] **P5-4** Providers — `organizationInvitationsProvider`, `OrganizationInvitationController`, `invitationDetailsProvider`, `InvitationAcceptController`
- [x] **P5-5** Screens — invite dialog (Members), `OrganizationInvitationsScreen`, `InvitationAcceptScreen`; owner **Invitations** entry
- [x] **P5-6** Routing — `/account/organization/invitations`, public `/org-invitation/:token`
- [x] **P5-7** Deep link + platform — `DeepLinkHandler`, `app.dart` presenter, AndroidManifest `pathPrefix`
- [x] **P5-8** Shared `PasswordRequirementsChecklist` + sign-up refactor
- [x] **P5-9** ARB strings (en + sr) + regen
- [x] **P5-10** Tests — repository/auth/deep-link/screens/controller (50/50 total)
- [x] **P5-11** Verify — `build_runner` ✅, `flutter analyze` ✅ 0 issues, raw-color scan ✅, `flutter test` ✅ 50/50
- [x] **P5-12** Docs — README invitations section; `docs/lessons_learned/10-organization-phase5-invitations.md`

### Phase 5 definition of done

An owner can invite an unregistered email, list and revoke invitations; the invitee opens
the email deep link, sees the invitation, sets a password, is registered verified/active,
joins as `ORG_MEMBER` and lands in the app; owner/member gating intact; analyze + tests
green; no raw colors. Android-only App Link (iOS Universal Links still absent).

**Status: met.** Confirmed by the user on device.

## Phase 2 checklist (fap-mobile)

- [x] **P2-1** Network constants — `organizationMembers`, `organizationMember`, `organizationTransferOwnership`
- [x] **P2-2** Models (freezed) — `organization_member_model.dart` (+ `roleValue`/`isOwner`/`displayName`), `transfer_ownership_request.dart`
- [x] **P2-3** Repository — `getMembers`, `removeMember`, `transferOwnership`
- [x] **P2-4** Providers — `organizationMembersProvider`, `OrganizationMemberController` (`remove` / `transferOwnership`)
- [x] **P2-5** Screen — `organization_members_screen.dart`; **Members** entry on `OrganizationScreen`
- [x] **P2-6** Routing — nested `/account/organization/members`
- [x] **P2-7** ARB strings (en + sr) + regen
- [x] **P2-8** Tests — repository (getMembers/remove/transfer/403), screen (render/role gating/empty/remove/transfer)
- [x] **P2-9** Verify — `build_runner` ✅, `flutter analyze` ✅ 0 issues, raw-color scan ✅, `flutter test` ✅ 27/27
- [x] **P2-10** Docs — README members section; `docs/lessons_learned/09-organization-phase2-members.md`

### Phase 2 definition of done

A member or owner can view the organization member list; the owner can remove a non-owner
member and transfer ownership (with confirmation); a plain member sees no management
actions; `flutter analyze` and `flutter test` are green; no raw color literals outside
`lib/core/theme/`.

**Status: met.** Confirmed by the user on device (ownership transfer tested).

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
| D8 | Members list readable by all members; remove/transfer are owner-only actions in a per-row overflow menu; the owner's own row has no actions | Accepted |
| D9 | After a successful ownership transfer, invalidate the membership so the caller's role (and the role-gated UI) refreshes | Accepted |
| D10 | Invite is a modal dialog (email only) from the Members screen; invitations list + revoke is a separate `/account/organization/invitations` screen | Accepted |
| D11 | Invitee acceptance is Android-only (HTTPS App Link); iOS Universal Links remain unconfigured | Accepted |
| D12 | `InvitationAcceptController` lives in its own provider file to avoid an auth↔organization provider import cycle | Accepted |
| D13 | No `fap-infra` change for `/org-invitation` — `assetlinks.json` already declares `handle_all_urls` | Accepted |

## Progress log

> Newest first. Each entry: date — step — what was done — files — verification — blockers.

- **2026-09-20 — Phase 2 & Phase 5 accepted on device ✅.**
  - **What:** User tested the member ownership transfer (Phase 2) and the full invitation
    flow (Phase 5) end-to-end on device — all scoped behaviour works.
  - **Verification:** manual device test — passed. Automated: `flutter test` 50/50,
    `flutter analyze` 0 issues.
  - **Blockers:** none. Both phases closed.

- **2026-09-20 — Phase 5 (Invitations & invitee acceptance) implemented and verified ✅.**
  - **What:** Owner invites/list/revoke + public invitee acceptance.
    - Constants: invitation paths (org-scoped + public details/accept).
    - Models: `OrganizationInvitationModel`, `OrganizationInvitationStatus`,
      `CreateInvitationRequest`, `OrganizationInvitationDetailsModel`,
      `InvitedRegistrationRequest`.
    - Repository: `inviteMember`, `getInvitations`, `revokeInvitation`,
      `getInvitationDetails`, `acceptInvitation`; `AuthRepository.registerInvited`.
    - Providers: `organizationInvitationsProvider`, `OrganizationInvitationController`,
      `invitationDetailsProvider`, `InvitationAcceptController` (register → persist tokens →
      accept).
    - Screens: invite dialog (Members), `OrganizationInvitationsScreen`,
      `InvitationAcceptScreen`; owner **Invitations** entry.
    - Routing: `/account/organization/invitations`, public `/org-invitation/:token`.
    - Deep link: `DeepLinkHandler` + `app.dart` presenter + AndroidManifest `pathPrefix`.
    - Shared `PasswordRequirementsChecklist` extracted; sign-up refactored to use it.
    - l10n: ~30 keys (en + sr).
    - Tests: +23 across repository/auth/deep-link/invitations/accept/controller/members.
  - **Verification:** `build_runner` ✅ · `flutter analyze` ✅ 0 issues · raw-color scan ✅ ·
    `flutter test` ✅ 50/50.
  - **Blockers:** none. Phase 6 closed as not required (no infra change).

- **2026-09-20 — Phase 2 (Members & ownership) implemented and verified ✅.**
  - **What:** Member list + owner-only remove/transfer.
    - Constants: `organizationMembers(id)`, `organizationMember(id, memberId)`,
      `organizationTransferOwnership(id)`.
    - Models: `OrganizationMemberModel` (`roleValue`/`isOwner`/`displayName`),
      `TransferOwnershipRequest`.
    - Repository: `getMembers`, `removeMember`, `transferOwnership`.
    - Providers: `organizationMembersProvider`; `OrganizationMemberController`
      (`remove`, `transferOwnership` — the latter also invalidates the membership).
    - Screen: `OrganizationMembersScreen` (member-visible list; per-row overflow menu with
      remove/transfer for owner, hidden on the owner's own row); **Members** secondary
      button added to `OrganizationScreen`.
    - Routing: `/account/organization/members`.
    - l10n: 12 new keys (en + sr).
    - Tests: repository (+4: getMembers ×2, remove, transfer, 403 mapping), screen (+5:
      render, empty, owner menu, member no-menu, remove flow, transfer flow).
  - **Verification:** `build_runner` ✅ · `flutter analyze` ✅ 0 issues · raw-color scan ✅ ·
    `flutter test` ✅ 27/27.
  - **Blockers:** none.

- **2026-09-20 — Phase 1 test coverage expanded + docs added.**
  - **What:** Closed test gaps and documented the phase.
    - Tests: added `getOrganization` + 404 mapping to
      `test/organization_repository_test.dart`; added an error+retry case to
      `test/organization_screen_test.dart`; added `test/organization_form_screen_test.dart`
      (create validation + edit prefill).
    - Docs: README "Organization (Phase 1)" and "Testing" sections;
      `docs/lessons_learned/08-organization-phase1.md`.
  - **Verification:** `flutter test` ✅ 16/16; `flutter analyze` ✅ 0 issues.
  - **Blockers:** none.

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
