# Registration Plates Phase 3 (Licence Plates) — Lessons Learned

## Overview

Phase 3 delivered the Account → Licence Plates area, replacing the earlier
"fleet vehicles" plan. One screen serves both audiences because the backend resolves
the scope:

- A **private user** (no organization) manages personal vehicle registration plates.
- An **`ORG_OWNER`** manages the organization's fleet plates.
- An **`ORG_MEMBER`** sees the fleet plates **read-only**.

Tracking doc:
[`docs/organization_implementation_plan_with_progress_status.md`](../organization_implementation_plan_with_progress_status.md).
Designs:
[`../../design/registration_plates_screen`](../../design/registration_plates_screen/private) and
[`../../design/registration_plates_screen`](../../design/registration_plates_screen/organization).

---

## Backend API change (important)

`fap-service` consolidated the previous endpoints into a **single resource**:

| Method | Path | Notes |
|---|---|---|
| GET | `/v1/registration-plates` | fleet plates if the caller belongs to an org (any member), else personal; newest first |
| POST | `/v1/registration-plates` | `organizationId` present → fleet (caller must be `ORG_OWNER`); absent → personal; 409 duplicate |
| GET | `/v1/registration-plates/{id}` | personal owner or `ORG_OWNER` |
| PUT | `/v1/registration-plates/{id}` | ownership immutable; 409 duplicate |
| DELETE | `/v1/registration-plates/{id}` | personal owner or `ORG_OWNER` |

`RegistrationPlateRequest`: `number` (required, ≤20), `registrationDate`, `expiresAt`,
`city` (≤50), `country` (≤50), `organizationId?`.
`RegistrationPlateDto` adds `expiresAt` and server-computed `expiresSoon` (30-day default).
Dates are ISO `yyyy-MM-dd`.

**Consequence:** the previously planned `fap-service` hand-off for a fleet-delete endpoint
was **not needed** — delete already exists in the unified API. Always re-fetch the live
OpenAPI spec before planning; the resource had been redesigned since the initial brief.

---

## Files Created / Modified

| File | Purpose |
|---|---|
| [`lib/core/network/api_constants.dart`](../../lib/core/network/api_constants.dart) | `registrationPlates`, `registrationPlate(id)`; removed stale `vehicleRegistrationPlate` |
| [`registrationplate`](../../lib/features/registrationplate/data/models/registration_plate_model.dart) | **New.** Read model + `isFleet`, `registrationDateValue`, `expiresAtValue`, `isExpiringSoon` |
| [`registrationplate`](../../lib/features/registrationplate/data/models/registration_plate_request.dart) | **New.** Writable request |
| [`registrationplate`](../../lib/features/registrationplate/data/repositories/registration_plate_repository.dart) | **New.** List/create/update/delete |
| [`registrationplate`](../../lib/features/registrationplate/presentation/providers/registration_plate_providers.dart) | **New.** Repository provider, list provider, `RegistrationPlateController` |
| [`registrationplate`](../../lib/features/registrationplate/presentation/screens/registration_plates_screen.dart) | **New.** Private + fleet list screen |
| [`registrationplate`](../../lib/features/registrationplate/presentation/screens/registration_plate_form_screen.dart) | **New.** Create/edit form with date pickers |
| [`lib/core/router/app_router.dart`](../../lib/core/router/app_router.dart) | `/account/plates`, `/add`, `/:id/edit` |
| [`lib/features/account/presentation/screens/account_screen.dart`](../../lib/features/account/presentation/screens/account_screen.dart) | Wired `Licence Plates` row; removed `Add New Plate` button |
| [`lib/features/auth/presentation/providers/auth_providers.dart`](../../lib/features/auth/presentation/providers/auth_providers.dart) | Invalidate `registrationPlatesProvider` on login/logout |
| `lib/l10n/app_en.arb`, `lib/l10n/app_sr.arb` | ~30 new keys |
| `../../test/registration_repository_test.dart`, `../../test/registration_plates_screen_test.dart`, `../../test/registration_plate_form_screen_test.dart` | **New.** 18 tests |

---

## Key lessons

1. **Re-resolve the contract every time.** The unified `/v1/registration-plates` resource
   did not exist when the Phase 3 plan was written. Fetching the live spec first avoided
   building against dead endpoints and removed a cross-repo hand-off.

2. **One screen, server-resolved scope.** Because `GET /v1/registration-plates` decides
   personal vs fleet server-side, the mobile side does not branch the data source — only
   the management affordances. Gating is `canManage = !hasOrganization || isOwner`.

3. **`organizationId` is create-only.** Ownership is immutable on update, so edit requests
   intentionally leave `organizationId` null.

4. **Riverpod `update` name clash.** `AsyncNotifier` already defines `update(cb, {onError})`.
   Naming a controller method `update` fails with `invalid_override`; use `updatePlate`.

5. **freezed + `@JsonSerializable` don't mix at class level.** Adding
   `@JsonSerializable(includeIfNull: false)` to a freezed class produced a duplicate
   `_$…ToJson` declaration. Nulls in the request payload are harmless (the backend uses
   `StringUtils.hasText`), so the annotation was dropped.

6. **Design tokens over raw values.** The plate cards reuse `GlassCard`, `theme.colorScheme.*`
   and the existing dark constants; the raw-color scan stays clean (only
   `Colors.transparent` outside `lib/core/theme/`).

7. **Missing design fields.** The fleet mock showed a vehicle model ("Mercedes EQS") and
   "Autocharge On"; neither exists in the DTO. They were omitted and the registration date
   is shown instead.

---

## Verification

```bash
dart run build_runner build
flutter analyze        # 0 issues
flutter test           # 68/68 passing (18 new)
# raw-color scan: zero matches outside lib/core/theme/
```

On-device acceptance: pending.
