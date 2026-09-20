# Organization Phase 2 (Members & Ownership) — Lessons Learned

## Overview

Phase 2 added the **member management** slice of the organization area in `fap-mobile`.
From **Account → Organization → Members** (`/account/organization/members`) a user can view
the organization's members; an `ORG_OWNER` can additionally **remove** a member and
**transfer ownership**.

End-to-end:

1. `GET /v1/organizations/{id}/members` lists members (any member can read).
2. Each non-owner row shows an owner-only overflow menu:
   - **Remove member** → `DELETE /v1/organizations/{id}/members/{memberId}`.
   - **Transfer ownership** → `POST /v1/organizations/{id}/transfer-ownership`
     (`{ memberId }`) — demotes the caller and promotes the target.
3. Both actions confirm first; a transfer invalidates the membership so the caller's role
   (and the role-gated UI) refreshes.

Inviting new members is Phase 5. Tracking doc:
[`docs/organization_implementation_plan_with_progress_status.md`](../organization_implementation_plan_with_progress_status.md).

---

## Files Created / Modified

| File | Purpose |
|---|---|
| [`lib/features/organization/data/models/organization_member_model.dart`](../../lib/features/organization/data/models/organization_member_model.dart) | **New.** Member model + `roleValue` / `isOwner` / `displayName` |
| [`lib/features/organization/data/models/transfer_ownership_request.dart`](../../lib/features/organization/data/models/transfer_ownership_request.dart) | **New.** `{ memberId }` body |
| [`lib/features/organization/data/repositories/organization_repository.dart`](../../lib/features/organization/data/repositories/organization_repository.dart) | `getMembers`, `removeMember`, `transferOwnership` |
| [`lib/features/organization/presentation/providers/organization_providers.dart`](../../lib/features/organization/presentation/providers/organization_providers.dart) | `organizationMembersProvider`; `OrganizationMemberController` |
| [`lib/features/organization/presentation/screens/organization_members_screen.dart`](../../lib/features/organization/presentation/screens/organization_members_screen.dart) | **New.** Member list + owner-only actions |
| [`lib/features/organization/presentation/screens/organization_screen.dart`](../../lib/features/organization/presentation/screens/organization_screen.dart) | **Members** secondary button |
| [`lib/core/network/api_constants.dart`](../../lib/core/network/api_constants.dart) | `organizationMembers`, `organizationMember`, `organizationTransferOwnership` |
| [`lib/core/router/app_router.dart`](../../lib/core/router/app_router.dart) | `/account/organization/members` |
| [`lib/l10n/app_en.arb`](../../lib/l10n/app_en.arb) / [`app_sr.arb`](../../lib/l10n/app_sr.arb) | 12 new member/ownership keys |
| [`test/organization_repository_test.dart`](../../test/organization_repository_test.dart) | getMembers / remove / transfer / 403 mapping |
| [`test/organization_members_screen_test.dart`](../../test/organization_members_screen_test.dart) | **New.** Render, role gating, empty, remove + transfer flows |

---

## Key Decisions

### 1. The members provider composes the membership provider
`organizationMembersProvider` awaits `organizationMembershipProvider`, short-circuits to an
empty list when the user has no organization, and otherwise calls
`getMembers(membership.organizationId)`. This mirrors the Phase 1 `organizationProvider`
and keeps the org id in one place.

### 2. Owner-only actions live in a per-row overflow menu
The list is readable by every member, but only the owner sees a `PopupMenuButton` — and only
on rows that are **not** the owner. The backend forbids removing the owner ("transfer
ownership first"), so the UI never offers an action that would 403.

### 3. Transfer invalidates the membership, not just the member list
After a transfer the caller is demoted to `ORG_MEMBER`, so the role-gated UI on the
organization screen must change. `OrganizationMemberController.transferOwnership`
invalidates both `organizationMembersProvider` and `organizationMembershipProvider`.

### 4. Irreversible actions always confirm
Remove and transfer are destructive/irreversible, so both go through an `AlertDialog`
whose body names the target member (`removeMemberConfirmBody(name)` /
`transferOwnershipConfirmBody(name)`).

---

## Lessons Learned

### 1. Popup menu item and dialog action can share the same text
The overflow menu item and the transfer dialog's confirm button are both
**"Transfer ownership"**. After `tap(menuItem)` + `pumpAndSettle()` the menu has closed, so
the dialog action is the remaining match — disambiguate with `find.text('Transfer ownership').last`.
For remove, the menu item ("Remove member") and dialog action ("Remove") differ, so no
disambiguation is needed. Always `pumpAndSettle()` between opening the menu and tapping its
item, and again before tapping the dialog action.

### 2. Reuse the icon-tile constants for the member avatar
The member avatar circle reuses `iconTileBackgroundLight` / `iconTileBackgroundDark` with
`brandPrimary` / `vibrantCyan` icons — the same tokens as the Account menu icon tiles. No
new color constant, no raw literal.

### 3. Avoid Riverpod reserved method names (again)
As in Phase 1 (`update`), the member controller's public methods are `remove` and
`transferOwnership` — neither collides with `AsyncNotifier` members (`build`, `state`,
`update`, `ref`).

### 4. A computed `displayName` keeps the UI null-safe
`OrganizationMemberModel.displayName` falls back from `firstName + lastName` to `email`,
so rows never render an empty title and the confirmation dialogs always have a label.

### 5. Backend role rules drive UI rules
The owner cannot be removed and the target of a transfer must be a member other than the
caller. Encoding those rules in the UI (hide the menu on the owner's row) avoids surfacing
`403` responses for actions the user should never have been offered.

---

## Verification

```bash
dart run build_runner build        # models/providers
flutter analyze                    # 0 issues
flutter test                       # 27/27 passing
```

Phase 2 test additions:

- `test/organization_repository_test.dart` — `getMembers` (roles + empty/non-list), `removeMember`
  (DELETE path), `transferOwnership` (POST path + `memberId` body), 403 `ProblemDetail` mapping.
- `test/organization_members_screen_test.dart` — list render + role chips, empty state, owner
  sees the action menu only for non-owner rows, a plain member sees no menu, remove flow
  issues `DELETE`, transfer flow issues `POST` with the right body.

---

## Follow-ups

1. **Phase 3 — Fleet vehicles:** `GET/POST /v1/organizations/{id}/vehicles`.
2. **Phase 4 — Fleet payment cards:** CRUD + primary; display issuer + primary + last-4 only.
3. **Phase 5 — Invitations:** owner invite/list/revoke + invitee deep link
   (`https://dev.fap.rs/org-invitation?token=…`), invited sign-up with `invitationToken`,
   and a `fap-infra` `assetlinks.json` hand-off.
4. **Manual device check:** ✅ done — owner vs member and ownership transfer verified on device.
