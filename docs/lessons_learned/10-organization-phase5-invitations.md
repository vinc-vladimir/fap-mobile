# Organization Phase 5 (Invitations & Invitee Acceptance) — Lessons Learned

## Overview

Phase 5 completed the organization invitation flow end-to-end:

1. An `ORG_OWNER` invites a **not-yet-registered** email from the Members screen (modal
   dialog) → `POST /v1/organizations/{id}/invitations`.
2. The owner can list and revoke invitations at `/account/organization/invitations`
   (`GET` / `DELETE .../invitations/{invitationId}`).
3. The invitee receives an email deep link
   (`https://dev.fap.rs/org-invitation?token=…`), opens the app, sees the invitation, sets a
   password → `POST /v1/auth/registration` with `invitationToken` (account created **already
   verified/active**, tokens returned), then `POST /v1/invitations/{token}/accept` → joins
   as `ORG_MEMBER` and lands in the app.

Tracking doc:
[`docs/organization_implementation_plan_with_progress_status.md`](../organization_implementation_plan_with_progress_status.md).

---

## Files Created / Modified

| File | Purpose |
|---|---|
| [`lib/features/organization/data/models/organization_invitation_status.dart`](../../lib/features/organization/data/models/organization_invitation_status.dart) | **New.** `PENDING`/`ACCEPTED`/`REVOKED`/`EXPIRED` enum |
| [`lib/features/organization/data/models/organization_invitation_model.dart`](../../lib/features/organization/data/models/organization_invitation_model.dart) | **New.** Invitation row model |
| [`lib/features/organization/data/models/create_invitation_request.dart`](../../lib/features/organization/data/models/create_invitation_request.dart) | **New.** `{ email }` |
| [`lib/features/organization/data/models/organization_invitation_details_model.dart`](../../lib/features/organization/data/models/organization_invitation_details_model.dart) | **New.** Public invitation details |
| [`lib/features/organization/data/repositories/organization_repository.dart`](../../lib/features/organization/data/repositories/organization_repository.dart) | `inviteMember`, `getInvitations`, `revokeInvitation`, `getInvitationDetails`, `acceptInvitation` |
| [`lib/features/auth/data/models/auth_models.dart`](../../lib/features/auth/data/models/auth_models.dart) | **New** `InvitedRegistrationRequest` |
| [`lib/features/auth/data/repositories/auth_repository.dart`](../../lib/features/auth/data/repositories/auth_repository.dart) | **New** `registerInvited` (returns tokens) |
| [`lib/features/organization/presentation/providers/organization_providers.dart`](../../lib/features/organization/presentation/providers/organization_providers.dart) | `organizationInvitationsProvider`; `OrganizationInvitationController` |
| [`lib/features/organization/presentation/providers/invitation_accept_provider.dart`](../../lib/features/organization/presentation/providers/invitation_accept_provider.dart) | **New.** `invitationDetailsProvider` + `InvitationAcceptController` |
| [`lib/features/organization/presentation/widgets/invite_member_dialog.dart`](../../lib/features/organization/presentation/widgets/invite_member_dialog.dart) | **New.** Invite dialog |
| [`lib/features/organization/presentation/screens/organization_invitations_screen.dart`](../../lib/features/organization/presentation/screens/organization_invitations_screen.dart) | **New.** Invitations list + revoke |
| [`lib/features/organization/presentation/screens/invitation_accept_screen.dart`](../../lib/features/organization/presentation/screens/invitation_accept_screen.dart) | **New.** Public accept screen |
| [`lib/features/organization/presentation/screens/organization_members_screen.dart`](../../lib/features/organization/presentation/screens/organization_members_screen.dart) | Owner **INVITE MEMBER** button |
| [`lib/features/organization/presentation/screens/organization_screen.dart`](../../lib/features/organization/presentation/screens/organization_screen.dart) | Owner **Invitations** entry |
| [`lib/features/auth/presentation/widgets/password_requirements_checklist.dart`](../../lib/features/auth/presentation/widgets/password_requirements_checklist.dart) | **New.** Extracted shared checklist |
| [`lib/features/auth/presentation/screens/sign_up_screen.dart`](../../lib/features/auth/presentation/screens/sign_up_screen.dart) | Refactored to use the shared checklist |
| [`lib/core/deep_links/deep_link_handler.dart`](../../lib/core/deep_links/deep_link_handler.dart) | `org-invitation` → `/org-invitation/<token>` |
| [`lib/app/app.dart`](../../lib/app/app.dart) | Presents `InvitationAcceptScreen` on the navigator |
| [`lib/core/router/app_router.dart`](../../lib/core/router/app_router.dart) | `/account/organization/invitations`, public `/org-invitation/:token` |
| [`android/app/src/main/AndroidManifest.xml`](../../android/app/src/main/AndroidManifest.xml) | `pathPrefix="/org-invitation"` App Link |
| [`lib/l10n/app_en.arb`](../../lib/l10n/app_en.arb) / [`app_sr.arb`](../../lib/l10n/app_sr.arb) | ~30 invitation keys |

---

## Key Decisions

### 1. Invite dialog, separate invitations screen
Per the agreed UX: inviting is a quick modal **dialog** (email only) triggered from the
Members screen; the invitation list + revoke lives on its own
`/account/organization/invitations` screen reached from the Organization screen.

### 2. The accept flow lives in its own provider file
`InvitationAcceptController` needs both the **auth** providers (registration, session
storage, auth state) and the **organization** providers (accept, membership). Because
`auth_providers.dart` already imports `organization_providers.dart` (for membership
invalidation), putting the controller in either file would create a cycle. A dedicated
`invitation_accept_provider.dart` importing both avoids it.

### 3. Persist the session before accepting
The invited registration returns `access_token`/`refresh_token` (unlike the normal sign-up,
which returns nothing). The controller writes them to secure storage and unlocks the app
**before** calling `acceptInvitation`, so the shared Dio interceptor attaches the Bearer
token to the accept call.

### 4. No `fap-infra` change needed
`static/.well-known/assetlinks.json` already declares
`delegate_permission/common.handle_all_urls`, which covers every path on `dev.fap.rs`. A new
path therefore only needs the AndroidManifest `pathPrefix` — no infra change. (This is why
the previously-planned Phase 6 was closed as not required.)

### 5. Android-only App Link
iOS Universal Links are still not configured (no `applinks:` entitlement), so the HTTPS
invitation link opens the app on Android only — consistent with registration-confirm and
password-reset. A `fap://org-invitation` custom scheme is supported for manual `adb` testing.

---

## Lessons Learned

### 1. Riverpod `autoDispose` controller + `state =` after an async gap throws in unit tests
Reading `container.read(xProvider.notifier)` without a listener lets the autoDispose
provider dispose immediately, so the later `state = await AsyncValue.guard(...)` threw
*"Cannot use the Ref ... after it has been disposed."* Fix: keep it alive with
`container.listen(xProvider, (_, _) {})` (the app's widget `ref.watch` does this
automatically). This only affects direct provider unit tests.

### 2. Re-pumping the same widget type with different `ProviderScope` overrides reuses state
A single `testWidgets` that pumped `OrganizationMembersScreen` twice (owner then member)
kept the first container, so the second assertion saw stale state. Split into two separate
tests — each `testWidgets` gets a fresh binding/tree. (Using a unique `Key` on the root
widget is the alternative.)

### 3. Menu/button text and dialog action text collide — disambiguate with `.last`
As in Phase 2, the invitations row's **Revoke** button and the confirmation dialog's
**Revoke** action share the same label. After `tap` + `pumpAndSettle()` the dialog is on
top, so `find.text('Revoke').last` selects the dialog action.

### 4. Extract the password checklist once, reuse in both forms
The 5-rule checklist now lives in `PasswordRequirementsChecklist` (takes the current
password, computes each rule). The sign-up screen lost its five `bool` fields and the
invited-registration form reuses the same widget — one source of truth for the policy UI.
While extracting, the "met" accent was made theme-aware (`brandPrimary` light / `vibrantCyan`
dark) per the design-token rules.

### 5. Deep-link tokens are path params, presented on the navigator
`org-invitation` follows the proven confirm/reset pattern: a path-param token
(`/org-invitation/:token`) routed by `DeepLinkHandler`, and **presented directly on the
navigator** in `app.dart` (not via `go_router`) so the shell redirect can't hijack it while
logged out.

### 6. The invitee is always a new user
The backend only invites unregistered emails, and the invited registration path ignores the
`email`/`role` fields (email comes from the invitation). The mobile request therefore sends
only `{ password, invitationToken }`.

---

## Verification

```bash
dart run build_runner build        # models/providers
flutter analyze                    # 0 issues
flutter test                       # 50/50 passing
```

Phase 5 test additions:

- `test/organization_repository_test.dart` — invite (POST body), getInvitations (statuses),
  revoke (DELETE), getInvitationDetails (public GET), accept (POST), 400 mapping.
- `test/auth_repository_test.dart` — **new.** `register` body; `registerInvited` body +
  token parsing.
- `test/deep_link_handler_test.dart` — **new.** `org-invitation` (https + `fap://`) and
  regression coverage for confirm/reset.
- `test/organization_invitations_screen_test.dart` — **new.** Render/statuses, empty,
  revoke flow (`DELETE`).
- `test/invitation_accept_screen_test.dart` — **new.** Pending form, 410 expired, 404
  invalid, non-pending state.
- `test/invitation_accept_provider_test.dart` — **new.** Register → store tokens → accept
  ordering and request bodies.
- `test/organization_members_screen_test.dart` — invite button owner/member gating + dialog.

---

## Follow-ups

1. **Phase 3 — Fleet vehicles:** `GET/POST /v1/organizations/{id}/vehicles`.
2. **Phase 4 — Fleet payment cards:** CRUD + primary; display issuer + primary + last-4 only.
3. **iOS Universal Links:** still absent — the invitation link is Android-only for now.
4. **Manual device check:** ✅ done — invite → email → accept → member verified on device,
   including the expired/invalid link states.
