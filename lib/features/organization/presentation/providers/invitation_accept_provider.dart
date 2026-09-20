import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/storage/secure_storage.dart';
import '../../../account/presentation/providers/account_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/models/organization_invitation_details_model.dart';
import 'organization_providers.dart';

part 'invitation_accept_provider.g.dart';

/// Public invitation details for the accept screen (`GET /v1/invitations/{token}`).
/// Cached per token so a rebuild does not refetch.
@Riverpod(keepAlive: false)
Future<OrganizationInvitationDetailsModel> invitationDetails(
  Ref ref, {
  required String token,
}) async {
  return ref.watch(organizationRepositoryProvider).getInvitationDetails(token);
}

/// Completes the invitee flow: registers the invited user (verified + active),
/// persists the returned session, then accepts the invitation so the user
/// becomes an `ORG_MEMBER`.
///
/// Kept in its own file (importing both the auth and organization providers)
/// to avoid an import cycle between `auth_providers.dart` and
/// `organization_providers.dart`.
@riverpod
class InvitationAcceptController extends _$InvitationAcceptController {
  @override
  FutureOr<void> build() {}

  Future<void> accept({required String token, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // 1. Invited registration → tokens (account already verified/active).
      final response = await ref
          .read(authRepositoryProvider)
          .registerInvited(password: password, invitationToken: token);

      // 2. Persist the session so the Dio interceptor authenticates the accept
      //    call, and unlock the app.
      final storage = ref.read(secureStorageProvider);
      await storage.writeAccessToken(response.accessToken);
      final refreshToken = response.refreshToken;
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await storage.writeRefreshToken(refreshToken);
      }
      ref.read(authStateProvider.notifier).setAuthenticated(true);
      ref.invalidate(accountProvider);
      ref.invalidate(organizationMembershipProvider);

      // 3. Join the organization as ORG_MEMBER.
      await ref.read(organizationRepositoryProvider).acceptInvitation(token);
      ref.invalidate(organizationMembershipProvider);
    });
  }
}
