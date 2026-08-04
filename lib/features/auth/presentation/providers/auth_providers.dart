import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_providers.g.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

/// Handles email + password sign in. On success the JWT pair is persisted in
/// secure storage so the [AuthInterceptor] attaches it to subsequent requests.
///
/// `keepAlive` — the session state outlives any single screen, so the
/// controller must not be disposed while an async sign-in/sign-out is pending.
@Riverpod(keepAlive: true)
class LoginController extends _$LoginController {
  @override
  FutureOr<void> build() {}

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);

      final storage = ref.read(secureStorageProvider);
      await storage.writeAccessToken(response.accessToken);
      final refreshToken = response.refreshToken;
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await storage.writeRefreshToken(refreshToken);
      }
    });
  }

  /// Signs out: best-effort server call, then always clears the local session.
  Future<void> logout() async {
    try {
      await ref.read(authRepositoryProvider).logout();
    } catch (_) {
      // The server may be unreachable or the token already expired — the local
      // session is cleared regardless.
    }
    await ref.read(secureStorageProvider).clearTokens();
    state = const AsyncData<void>(null);
  }
}

@riverpod
class RegistrationController extends _$RegistrationController {
  @override
  FutureOr<void> build() {}

  Future<void> register({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .register(email: email, password: password),
    );
  }
}

/// POST /v1/auth/confirm/registration — verifies the email address with the
/// one-time token from the confirmation deep link.
@riverpod
Future<void> confirmRegistration(Ref ref, {required String token}) async {
  await ref.watch(authRepositoryProvider).confirmRegistration(token: token);
}
