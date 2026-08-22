import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_client.dart';
import '../../data/repositories/settings_repository.dart';

part 'settings_providers.g.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(dioProvider));
});

/// Handles the Change Password operation from the Settings screen.
@riverpod
class ChangePasswordController extends _$ChangePasswordController {
  @override
  FutureOr<void> build() {}

  Future<void> changePassword({
    required String password,
    required String confirmedPassword,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(settingsRepositoryProvider)
          .changePassword(
            password: password,
            confirmedPassword: confirmedPassword,
          ),
    );
  }
}

/// Handles the (soft) Delete Account operation from the Settings screen.
@riverpod
class DeleteAccountController extends _$DeleteAccountController {
  @override
  FutureOr<void> build() {}

  Future<void> deleteAccount() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(settingsRepositoryProvider).softDeleteAccount(),
    );
  }
}
