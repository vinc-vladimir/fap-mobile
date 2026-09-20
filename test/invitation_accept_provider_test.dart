import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fap_mobile/core/storage/secure_storage.dart';
import 'package:fap_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:fap_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:fap_mobile/features/organization/data/repositories/organization_repository.dart';
import 'package:fap_mobile/features/organization/presentation/providers/invitation_accept_provider.dart';
import 'package:fap_mobile/features/organization/presentation/providers/organization_providers.dart';

ResponseBody _json(String body) => ResponseBody.fromString(
  body,
  200,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

/// Routes registration → tokens, accept → organization, and records requests.
class _RoutingAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (options.path.endsWith('/v1/auth/registration')) {
      return _json('{"access_token":"acc","refresh_token":"ref"}');
    }
    if (options.path.endsWith('/accept')) {
      return _json('{"id":"org-1","name":"Acme","active":true}');
    }
    return ResponseBody.fromString('{}', 404);
  }

  @override
  void close({bool force = false}) {}
}

class _FakeSecureStorage extends SecureStorage {
  String? access;
  String? refresh;

  @override
  Future<String?> readAccessToken() async => access;

  @override
  Future<String?> readRefreshToken() async => refresh;

  @override
  Future<void> writeAccessToken(String token) async => access = token;

  @override
  Future<void> writeRefreshToken(String token) async => refresh = token;

  @override
  Future<void> clearTokens() async {
    access = null;
    refresh = null;
  }

  @override
  Future<bool> readPasskeyEnabled() async => false;
}

void main() {
  test(
    'accept registers the invitee, stores tokens and joins the org',
    () async {
      final adapter = _RoutingAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api'))
        ..httpClientAdapter = adapter;
      final storage = _FakeSecureStorage();

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(AuthRepository(dio)),
          organizationRepositoryProvider.overrideWithValue(
            OrganizationRepository(dio),
          ),
          secureStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);

      // Keep the autoDispose controller alive while the async work runs.
      container.listen(invitationAcceptControllerProvider, (_, _) {});

      await container
          .read(invitationAcceptControllerProvider.notifier)
          .accept(token: 'tok-1', password: 'Passw0rd!');

      expect(adapter.requests, hasLength(2));

      expect(adapter.requests.first.method, 'POST');
      expect(adapter.requests.first.path, '/v1/auth/registration');
      final registrationBody =
          adapter.requests.first.data as Map<String, dynamic>;
      expect(registrationBody['password'], 'Passw0rd!');
      expect(registrationBody['invitationToken'], 'tok-1');

      expect(adapter.requests.last.method, 'POST');
      expect(adapter.requests.last.path, '/v1/invitations/tok-1/accept');

      expect(storage.access, 'acc');
      expect(storage.refresh, 'ref');
    },
  );
}
