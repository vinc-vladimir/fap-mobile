# Organization Phase 1 (Profile CRUD + Membership) — Lessons Learned

## Overview

This phase delivered the first slice of the **organization (B2B fleet)** area in
`fap-mobile`: the Account tab → **Organization** now lets a user create, view, edit, and
deactivate their organization, with the UI gated by the caller's role
(`ORG_OWNER` / `ORG_MEMBER`).

End-to-end:

1. **Account → Organization** (`/account/organization`) resolves the caller's membership via
   `GET /v1/organizations/me`.
2. No organization → empty state + **CREATE ORGANIZATION** → `POST /v1/organizations`
   (the caller becomes `ORG_OWNER`).
3. Has organization → the profile is fetched with `GET /v1/organizations/{id}`; the owner
   sees **Edit** (`PUT /v1/organizations/{id}`) and **Deactivate**
   (`POST /v1/organizations/{id}/deactivate`); a member sees a read-only view.

Members, fleet vehicles, fleet payment cards, and invitations are deliberately deferred to
later phases. Tracking doc:
[`docs/organization_implementation_plan_with_progress_status.md`](../organization_implementation_plan_with_progress_status.md).

---

## Files Created / Modified

| File | Purpose |
|---|---|
| [`lib/features/organization/data/models/organization_model.dart`](../../lib/features/organization/data/models/organization_model.dart) | **New.** Read model (`freezed`) for the organization profile |
| [`lib/features/organization/data/models/organization_request.dart`](../../lib/features/organization/data/models/organization_request.dart) | **New.** Writable subset used for create/update |
| [`lib/features/organization/data/models/organization_membership_model.dart`](../../lib/features/organization/data/models/organization_membership_model.dart) | **New.** `{ organizationId, role }` from `/me` |
| [`lib/features/organization/data/models/organization_role.dart`](../../lib/features/organization/data/models/organization_role.dart) | **New.** `ORG_OWNER` / `ORG_MEMBER` enum with `unknown` fallback |
| [`lib/features/organization/data/repositories/organization_repository.dart`](../../lib/features/organization/data/repositories/organization_repository.dart) | **New.** `getMembership`, `createOrganization`, `getOrganization`, `updateOrganization`, `deactivateOrganization` |
| [`lib/features/organization/presentation/providers/organization_providers.dart`](../../lib/features/organization/presentation/providers/organization_providers.dart) | **New.** Repository + membership + profile providers; form/lifecycle controllers |
| [`lib/features/organization/presentation/screens/organization_screen.dart`](../../lib/features/organization/presentation/screens/organization_screen.dart) | **New.** Empty / profile / role-gated owner actions |
| [`lib/features/organization/presentation/screens/organization_form_screen.dart`](../../lib/features/organization/presentation/screens/organization_form_screen.dart) | **New.** Create / edit form |
| [`lib/core/network/api_constants.dart`](../../lib/core/network/api_constants.dart) | Added org paths; removed the stale `/v1/account/{accountId}/organization` |
| [`lib/core/router/app_router.dart`](../../lib/core/router/app_router.dart) | Nested `/account/organization`, `/create`, `/edit` |
| [`lib/features/account/presentation/screens/account_screen.dart`](../../lib/features/account/presentation/screens/account_screen.dart) | Wired the Organization menu row |
| [`lib/features/auth/presentation/providers/auth_providers.dart`](../../lib/features/auth/presentation/providers/auth_providers.dart) | Invalidate membership on login/logout |
| [`lib/l10n/app_en.arb`](../../lib/l10n/app_en.arb) / [`app_sr.arb`](../../lib/l10n/app_sr.arb) | ~24 new organization keys |
| [`test/organization_repository_test.dart`](../../test/organization_repository_test.dart) | Repository tests (Dio fake adapter) |
| [`test/organization_screen_test.dart`](../../test/organization_screen_test.dart) | Screen states + role gating |
| [`test/organization_form_screen_test.dart`](../../test/organization_form_screen_test.dart) | Form validation + edit prefill |

---

## Key Decisions

### 1. The backend contract was resolved from the live spec, not from memory
Per `AGENTS.md`, the endpoint/DTO summary tables are treated as drifting hints. The live
OpenAPI spec (`/v3/api-docs`) plus `fap-service/doc/openapi/organization-api.yaml` were the
source of truth. This immediately surfaced a **missing capability**: there was no endpoint
for the app to discover *which* organization the logged-in user belongs to, nor their role.
`AccountDto` had also dropped `organizationId`.

### 2. Missing backend capability → hand-off, not a client workaround
Because the membership lookup did not exist, a self-contained hand-off prompt was produced
for the `fap-service` agent (what/why/contract, implementation left to the owner). The
backend then added `GET /v1/organizations/me` returning
`{ organizationId, role }` (both `null` when the user has none), and the mobile work
resumed against the real contract.

### 3. Two-step membership lookup
`GET /v1/organizations/me` returns only `{ organizationId, role }`, so the profile is
fetched in a second call to `GET /v1/organizations/{id}`. The Riverpod `organizationProvider`
composes this: it awaits the membership, short-circuits to `null` when there is none, and
otherwise fetches the profile.

### 4. Writable request model, separate from the read model
`OrganizationRequest` contains only the writable fields (`name, crn, vat, phone, email,
address, city, zip, country`); `OrganizationModel` additionally carries server-managed
`id`, `active`, `createdAt`. This prevents accidental writes of server-owned fields and
keeps the two shapes honest.

### 5. Role gating reads the membership, not the profile
Owner-only actions are shown based on `membership.roleValue.isOwner`. The profile itself has
no role field, so the membership provider is the single source of truth for gating.

---

## Lessons Learned

### 1. Riverpod codegen: a controller method named `update` collides with `AsyncNotifier.update`
Naming a controller method `update(String, Request)` produced:

```
error • 'OrganizationFormController.update' isn't a valid override of
        '$AsyncClassModifier.update' ...
```

`AsyncNotifier`/`$AsyncClassModifier` already defines `update`. Renamed the method to
`updateOrganization`. **Rule of thumb:** avoid `update`, `build`, and `state` as public
method names on Riverpod notifiers.

### 2. Don't let a form widget return its own `Scaffold` inside an async wrapper
The edit flow wraps the form in an `AsyncValue.when` (loading/error/data). The form widget
also returned a `Scaffold` with the app bar, producing a **nested `Scaffold`**
(`Scaffold > Expanded > Scaffold`). Fix: the async wrapper owns the `Scaffold` + app bar;
the form returns only its body. For the create flow (no async gate) the wrapper supplies the
create app bar.

### 3. Capture `ScaffoldMessenger` before `await showDialog`
`ScaffoldMessenger.of(context)` after an `await` tripped
`use_build_context_synchronously`. Capture the messenger *before* the dialog await (and
still guard with `context.mounted` after the network call).

### 4. Freezed + nullable enums: prefer a string field + a computed getter
Instead of a custom `@JsonKey(fromJson: ...)` on a nullable enum (whose null handling is
easy to get wrong), the membership model stores `role` as `String?` and exposes
`OrganizationRole get roleValue => OrganizationRole.fromWire(role)` with an `unknown`
fallback. Simple, explicit, and tolerant of new server enum values.

### 5. `flutter test` needs the Xcode license on macOS
`flutter test` failed while *"Building assets for package: objective_c"* with
*"You have not agreed to the Xcode license agreements."* The `passkeys`/`objective_c`
native-assets build runs `xcrun` and `clang`, both gated behind the Xcode license — so this
breaks **all** tests (including the pre-existing `widget_test.dart`), not just new ones.
Fix once with `sudo xcodebuild -license accept` (or `sudo xcodebuild -runFirstLaunch`).
A PATH shim for `xcrun` is **not** sufficient: `clang` itself also enforces the license.

### 6. Tests without a mocking package
No mocking library is used. The repository tests implement a tiny `HttpClientAdapter` that
records the last `RequestOptions` and returns scripted JSON — the same pattern as the
existing `test/widget_test.dart`. This verifies method, path, and body (e.g. that
server-managed `id`/`active` are **not** sent) without adding a dependency.

### 7. Design-token discipline holds for new features
No raw color literals were introduced; the new screens use `theme.colorScheme.*`, named
constants from `app_colors.dart` (`vibrantCyan`, `brandPrimary`), `AppDimensions`, and
`GlassCard`. The mandated scan
(`Color(0x|Color.fromARGB|Color.fromRGBO|Colors.` outside `lib/core/theme/`, minus
`Colors.transparent`) stays clean.

---

## Verification

```bash
dart run build_runner build --delete-conflicting-outputs   # models/providers
flutter analyze                                            # 0 issues
flutter test                                               # 16/16 passing
```

Test breakdown:

- `test/organization_repository_test.dart` — membership (owner/member/null), create body,
  update, get, deactivate, RFC 7807 mapping (409 + 404).
- `test/organization_screen_test.dart` — empty state, owner actions, member gating, error+retry.
- `test/organization_form_screen_test.dart` — create validation, edit prefill.
- `test/widget_test.dart` — existing app smoke test.

Confirmed on device by the user: create / view / edit / deactivate, membership resolution,
and owner-vs-member gating all work.

---

## Follow-ups

1. **Phase 2 — Members & ownership:** `GET /v1/organizations/{id}/members`,
   `DELETE .../members/{memberId}`, `POST .../transfer-ownership`.
2. **Phase 3 — Fleet vehicles:** `GET/POST /v1/organizations/{id}/vehicles`.
3. **Phase 4 — Fleet payment cards:** CRUD + primary; display issuer + primary + last-4 only.
4. **Phase 5 — Invitations:** owner invite/list/revoke + invitee deep link
   (`https://dev.fap.rs/org-invitation?token=…`), invited sign-up with `invitationToken`
   (requires an auth-registration change), and a `fap-infra` `assetlinks.json` hand-off.
5. **Stale `AccountModel.organizationId`:** the backend no longer returns it; the unused
   field can be removed in a cleanup pass.
