import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_client.dart';
import '../../data/models/account_model.dart';
import '../../data/repositories/account_repository.dart';

part 'account_provider.g.dart';

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository(ref.watch(dioProvider));
});

/// The account profile of the logged-in user.
///
/// `autoDispose` — the cached result lives only while the account area is
/// mounted, so it is not served across sign-out/sign-in sessions. It is
/// explicitly invalidated after mutations (password change) and on successful
/// sign-in so the Settings screen always shows fresh `passwordChangedAt` /
/// `createdAt`.
@Riverpod(keepAlive: false)
Future<AccountModel?> account(Ref ref) async {
  return ref.watch(accountRepositoryProvider).getAccount();
}
