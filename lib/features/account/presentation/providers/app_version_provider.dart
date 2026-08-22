import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/health_providers.dart';

part 'app_version_provider.g.dart';

/// Build/version metadata of the running fap-service, fetched once from the
/// Spring Boot Actuator (`GET /actuator/info` on the management port).
@Riverpod(keepAlive: true)
Future<String?> appVersion(Ref ref) async {
  final repo = ref.watch(healthRepositoryProvider);
  try {
    final info = await repo.fetchServiceInfo();
    return info.build?.version;
  } catch (_) {
    return null;
  }
}
