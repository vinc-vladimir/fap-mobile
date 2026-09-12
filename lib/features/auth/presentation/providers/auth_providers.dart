import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/jwt_utils.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../account/presentation/providers/account_provider.dart';

part 'auth_providers.g.dart';

/// Session state read synchronously by the router's guard.
///
/// - [AuthStatus.loggedOut] — no usable session; protected routes redirect to
///   sign-in.
/// - [AuthStatus.biometricLocked] — a valid session exists but the user has a
///   registered passkey, so the app re-prompts for a biometric scan before
///   showing the shell.
/// - [AuthStatus.loggedIn] — fully unlocked; protected routes are reachable.
enum AuthStatus { loggedOut, biometricLocked, loggedIn }

/// The session state, restored from secure storage on first build (cold start)
/// and updated in-memory by [LoginController] / [PasskeyLoginController] when
/// the user signs in/out. The restored token is validated against
/// `GET /v1/account`; if the server rejects it (401/403) the token is cleared
/// so the guard stays on sign-in.
///
/// When a valid session is restored AND a passkey is registered for the
/// account, the state becomes [AuthStatus.biometricLocked] instead of
/// [AuthStatus.loggedIn] — the app re-opens behind the biometric gate (P1-8).
@Riverpod(keepAlive: true)
class AuthState extends _$AuthState {
  @override
  AuthStatus build() {
    _restorePersistedSession();
    return AuthStatus.loggedOut;
  }

  Future<void> _restorePersistedSession() async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.readAccessToken();
    if (token == null || token.isEmpty) return;

    // Local passkey flag — source of truth until backend G2 ships a
    // server-side credential list (decision D5).
    final passkeyEnabled = await storage.readPasskeyEnabled();

    try {
      // Validate the restored token against the backend. A 2xx from
      // GET /v1/account confirms the session is still usable.
      await ref.read(accountRepositoryProvider).getAccount();
      state = passkeyEnabled ? AuthStatus.biometricLocked : AuthStatus.loggedIn;
    } on ApiException catch (e) {
      final statusCode = e.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        // Token rejected/expired — drop it so the router guard keeps the user
        // on the sign-in screen. (The AuthInterceptor also clears on 401.)
        await storage.clearTokens();
      } else if (statusCode == null) {
        // Server unreachable — cannot validate, so keep the stored session
        // rather than logging the user out on a transient network failure.
        state = passkeyEnabled
            ? AuthStatus.biometricLocked
            : AuthStatus.loggedIn;
      }
    }
  }

  void setAuthenticated(bool value) =>
      state = value ? AuthStatus.loggedIn : AuthStatus.loggedOut;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

/// The signed-in user's email, decoded from the persisted access token's `sub`
/// claim. `null` when no token is stored or it cannot be decoded.
///
/// `keepAlive` so it survives screen navigation; invalidated on sign-in and
/// sign-out so it never serves a previous session's email.
@Riverpod(keepAlive: true)
Future<String?> currentUserEmail(Ref ref) async {
  final token = await ref.watch(secureStorageProvider).readAccessToken();
  if (token == null || token.isEmpty) return null;
  return emailFromJwt(token);
}

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
      ref.invalidate(currentUserEmailProvider);
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
    ref.invalidate(currentUserEmailProvider);
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

/// POST /v1/auth/forgotten/password/email — requests a password reset email.
///
/// Public endpoint. On success the UI shows the "Check Your Email" screen; the
/// email contains a link back into the app to set a new password.
@riverpod
class ForgottenPasswordEmailController
    extends _$ForgottenPasswordEmailController {
  @override
  FutureOr<void> build() {}

  Future<void> send({required String email}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .sendForgottenPasswordEmail(email: email),
    );
  }
}

/// POST /v1/auth/forgotten/password — sets a new password using the one-time
/// token from the reset email link.
///
/// Public endpoint; the backend returns no session, so the user signs in again
/// with the new password afterwards.
@riverpod
class ResetPasswordController extends _$ResetPasswordController {
  @override
  FutureOr<void> build() {}

  Future<void> reset({
    required String token,
    required String password,
    required String confirmedPassword,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .resetPassword(
            token: token,
            password: password,
            confirmedPassword: confirmedPassword,
          ),
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
