import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'api_client.dart';
import 'health_models.dart';
import 'health_repository.dart';

part 'health_providers.g.dart';

final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  return HealthRepository(ref.watch(managementDioProvider));
});

/// Derived backend status surfaced by the startup screen.
class ServerStatus {
  const ServerStatus({
    required this.isOnline,
    this.status,
    this.buildInfo,
    this.errorMessage,
  });

  final bool isOnline;

  /// Raw actuator health status (e.g. "UP", "DOWN").
  final String? status;

  final ServiceBuildInfo? buildInfo;

  /// Human-readable reason when the service could not be reached.
  final String? errorMessage;

  String? get version => buildInfo?.version;
  String? get artifact => buildInfo?.artifact;
}

/// Runs the actuator health probe (and version lookup) on startup.
@riverpod
class ServerStatusController extends _$ServerStatusController {
  @override
  Future<ServerStatus> build() => _check();

  Future<ServerStatus> _check() async {
    try {
      final repo = ref.read(healthRepositoryProvider);
      final health = await repo.checkHealth();

      ServiceBuildInfo? buildInfo;
      if (health.isUp) {
        final info = await repo.fetchServiceInfo();
        buildInfo = info.build;
      } else {
        debugPrint(
          '[FAP] fap-service health check: service is up but reports '
          'status "${health.status}" (not UP)',
        );
      }

      return ServerStatus(
        isOnline: health.isUp,
        status: health.status,
        buildInfo: buildInfo,
      );
    } catch (e) {
      debugPrint('[FAP] fap-service health check failed: $e');
      return ServerStatus(isOnline: false, errorMessage: e.toString());
    }
  }
}
