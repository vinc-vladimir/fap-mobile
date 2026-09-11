import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../account/presentation/providers/account_provider.dart';
import '../../data/repositories/passkey_repository.dart';
import '../../data/services/passkey_service.dart';
import 'auth_providers.dart';

part 'passkey_providers.g.dart';

final passkeyRepositoryProvider = Provider<PasskeyRepository>((ref) {
  return PasskeyRepository(ref.watch(dioProvider));
});

final passkeyServiceProvider = Provider<PasskeyService>(
  (ref) => PasskeyService(),
);

/// Whether a passkey is registered for the current account.
///
/// Local `FlutterSecureStorage` flag only — the source of truth becomes the
/// server once backend G2 ships `GET /v1/account/webauthn-credentials`
/// (decision D5). `keepAlive` so the flag survives screen navigation.
@Riverpod(keepAlive: true)
class PasskeyEnabled extends _$PasskeyEnabled {
  @override
  Future<bool> build() {
    return ref.watch(secureStorageProvider).readPasskeyEnabled();
  }

  Future<void> setEnabled(bool enabled) async {
    final storage = ref.read(secureStorageProvider);
    if (enabled) {
      await storage.writePasskeyEnabled(true);
    } else {
      await storage.clearPasskeyEnabled();
    }
    state = AsyncData(enabled);
  }
}

/// Handles the passkey registration ceremony from the Settings screen:
/// options → platform biometric → `POST /webauthn/register` → local flag on.
@Riverpod(keepAlive: true)
class PasskeyRegistrationController extends _$PasskeyRegistrationController {
  @override
  FutureOr<void> build() {}

  Future<void> registerPasskey() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(passkeyRepositoryProvider);
      final options = await repository.getRegisterOptions();
      final credential = await ref
          .read(passkeyServiceProvider)
          .register(options);
      await repository.register(
        credential: credential,
        label: _defaultDeviceLabel,
      );
      await ref.read(passkeyEnabledProvider.notifier).setEnabled(true);
    });
  }
}

/// Handles passkey sign-in: authenticate options → platform biometric →
/// `POST /v1/auth/login/webauthn` → persist JWT → mark session authenticated.
///
/// Used by both the Sign-in screen's biometric button and the biometric
/// re-open gate (P1-8). Navigation after success is driven by the router guard
/// reacting to `authStateProvider`.
@Riverpod(keepAlive: true)
class PasskeyLoginController extends _$PasskeyLoginController {
  @override
  FutureOr<void> build() {}

  Future<void> loginWithPasskey() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(passkeyRepositoryProvider);
      final options = await repository.getAuthenticateOptions();
      final assertion = await ref
          .read(passkeyServiceProvider)
          .authenticate(options);
      final response = await ref
          .read(authRepositoryProvider)
          .loginWithPasskey(assertion);

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
}

/// Device label sent as the backend credential label on registration.
String get _defaultDeviceLabel {
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'Android',
    TargetPlatform.iOS => 'iPhone',
    _ => 'Device',
  };
}
