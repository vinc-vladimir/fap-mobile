import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../account/presentation/providers/account_provider.dart';

part 'auth_providers.g.dart';

/// Whether a valid session (access token) is currently held. Read synchronously
/// by the router's guard so redirects see the correct value immediately after
/// login/logout — no async storage read that can return a stale cached `false`.
///
/// The value is restored from secure storage on first build (cold start) and
/// updated in-memory by [LoginController] when the user signs in/out.
@Riverpod(keepAlive: true)
class AuthState extends _$AuthState {
  @override
  bool build() {
    _restorePersistedSession();
    return false;
  }

  Future<void> _restorePersistedSession() async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      state = true;
    }
  }

  void setAuthenticated(bool value) => state = value;
}

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
      ref.read(authStateProvider.notifier).setAuthenticated(true);
      // Fresh session → drop any cached account data from a previous session.
      ref.invalidate(accountProvider);
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
    ref.read(authStateProvider.notifier).setAuthenticated(false);
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
///
/// This is a public action (the endpoint is `permitAll`), so it must not clear
/// stored tokens first: clearing them here once blocked the request if the
/// storage delete threw. Any stale-session cleanup belongs after a successful
/// confirm, not before the call.
///
/// `keepAlive` caches the per-token result so the (single-use) OTT is only
/// consumed once — a screen rebuild must not re-fire the request and flip a
/// successful confirmation to an "already consumed" failure.
@Riverpod(keepAlive: true)
Future<void> confirmRegistration(Ref ref, {required String token}) async {
  debugPrint('[confirmRegistration] provider run for token=$token');
  await ref.watch(authRepositoryProvider).confirmRegistration(token: token);
  debugPrint('[confirmRegistration] confirm completed for token=$token');
}
