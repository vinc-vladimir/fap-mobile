import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_client.dart';
import '../../data/models/organization_invitation_model.dart';
import '../../data/models/organization_member_model.dart';
import '../../data/models/organization_membership_model.dart';
import '../../data/models/organization_model.dart';
import '../../data/models/organization_request.dart';
import '../../data/repositories/organization_repository.dart';

part 'organization_providers.g.dart';

final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  return OrganizationRepository(ref.watch(dioProvider));
});

/// The organization membership of the logged-in user (`GET /v1/organizations/me`).
///
/// `autoDispose` — cached only while the organization area is mounted, so a
/// previous session's membership is never served across sign-out/sign-in. It is
/// invalidated after mutations (create/update/deactivate) and on successful
/// sign-in/out.
@Riverpod(keepAlive: false)
Future<OrganizationMembershipModel?> organizationMembership(Ref ref) async {
  return ref.watch(organizationRepositoryProvider).getMembership();
}

/// The full organization profile, resolved from the membership's
/// `organizationId`. Null when the user has no organization.
@Riverpod(keepAlive: false)
Future<OrganizationModel?> organization(Ref ref) async {
  final membership = await ref.watch(organizationMembershipProvider.future);
  final id = membership?.organizationId;
  if (id == null || id.isEmpty) return null;
  return ref.watch(organizationRepositoryProvider).getOrganization(id);
}

/// The members of the caller's organization. Empty when the user has no
/// organization. Requires membership on the backend (both owner and member can
/// read the list).
@Riverpod(keepAlive: false)
Future<List<OrganizationMemberModel>> organizationMembers(Ref ref) async {
  final membership = await ref.watch(organizationMembershipProvider.future);
  final id = membership?.organizationId;
  if (id == null || id.isEmpty) return const [];
  return ref.watch(organizationRepositoryProvider).getMembers(id);
}

/// The organization's invitations (owner-only on the backend). Empty when the
/// user has no organization.
@Riverpod(keepAlive: false)
Future<List<OrganizationInvitationModel>> organizationInvitations(
  Ref ref,
) async {
  final membership = await ref.watch(organizationMembershipProvider.future);
  final id = membership?.organizationId;
  if (id == null || id.isEmpty) return const [];
  return ref.watch(organizationRepositoryProvider).getInvitations(id);
}

/// Handles creating and updating the organization profile.
///
/// On success the cached membership/profile are invalidated so the Organization
/// screen refetches and reflects the change.
@riverpod
class OrganizationFormController extends _$OrganizationFormController {
  @override
  FutureOr<void> build() {}

  Future<void> create(OrganizationRequest request) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(organizationRepositoryProvider)
          .createOrganization(request);
      ref.invalidate(organizationMembershipProvider);
    });
  }

  Future<void> updateOrganization(
    String organizationId,
    OrganizationRequest request,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(organizationRepositoryProvider)
          .updateOrganization(organizationId, request);
      ref.invalidate(organizationProvider);
      ref.invalidate(organizationMembershipProvider);
    });
  }
}

/// Handles the organization lifecycle (soft delete / deactivate).
@riverpod
class OrganizationLifecycleController
    extends _$OrganizationLifecycleController {
  @override
  FutureOr<void> build() {}

  Future<void> deactivate(String organizationId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(organizationRepositoryProvider)
          .deactivateOrganization(organizationId);
      ref.invalidate(organizationProvider);
      ref.invalidate(organizationMembershipProvider);
    });
  }
}

/// Handles owner-only member mutations: remove a member and transfer ownership.
///
/// Both invalidate the members list; a transfer also changes the caller's role,
/// so the membership (and thus the role-gated UI) is refreshed too.
@riverpod
class OrganizationMemberController extends _$OrganizationMemberController {
  @override
  FutureOr<void> build() {}

  Future<void> remove(String organizationId, String memberId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(organizationRepositoryProvider)
          .removeMember(organizationId, memberId);
      ref.invalidate(organizationMembersProvider);
    });
  }

  Future<void> transferOwnership(String organizationId, String memberId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(organizationRepositoryProvider)
          .transferOwnership(organizationId, memberId);
      ref.invalidate(organizationMembersProvider);
      ref.invalidate(organizationMembershipProvider);
    });
  }
}

/// Handles owner-only invitation mutations: invite a new email and revoke a
/// pending invitation. Both invalidate the invitations list.
@riverpod
class OrganizationInvitationController
    extends _$OrganizationInvitationController {
  @override
  FutureOr<void> build() {}

  Future<void> invite(String organizationId, String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(organizationRepositoryProvider)
          .inviteMember(organizationId, email);
      ref.invalidate(organizationInvitationsProvider);
    });
  }

  Future<void> revoke(String organizationId, String invitationId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(organizationRepositoryProvider)
          .revokeInvitation(organizationId, invitationId);
      ref.invalidate(organizationInvitationsProvider);
    });
  }
}
