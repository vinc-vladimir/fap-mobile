import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_client.dart';
import '../../data/models/registration_plate_model.dart';
import '../../data/models/registration_plate_request.dart';
import '../../data/repositories/registration_plate_repository.dart';

part 'registration_plate_providers.g.dart';

final registrationPlateRepositoryProvider =
    Provider<RegistrationPlateRepository>((ref) {
      return RegistrationPlateRepository(ref.watch(dioProvider));
    });

/// The registration plates visible to the logged-in user.
///
/// The backend resolves the scope: organization fleet plates when the caller is
/// a member of an organization, otherwise the caller's personal plates.
///
/// `autoDispose` — cached only while the registration plates area is mounted, so
/// a previous session's plates are never served across sign-out/sign-in. It is
/// invalidated after create/update/delete and on successful sign-in/out.
@Riverpod(keepAlive: false)
Future<List<RegistrationPlateModel>> registrationPlates(Ref ref) async {
  return ref.watch(registrationPlateRepositoryProvider).getRegistrationPlates();
}

/// Handles registration plate mutations (create, update, delete).
///
/// On success the cached list is invalidated so the Registration Plates screen
/// refetches and reflects the change.
@riverpod
class RegistrationPlateController extends _$RegistrationPlateController {
  @override
  FutureOr<void> build() {}

  Future<void> create(RegistrationPlateRequest request) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(registrationPlateRepositoryProvider)
          .createRegistrationPlate(request);
      ref.invalidate(registrationPlatesProvider);
    });
  }

  Future<void> updatePlate(String id, RegistrationPlateRequest request) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(registrationPlateRepositoryProvider)
          .updateRegistrationPlate(id, request);
      ref.invalidate(registrationPlatesProvider);
    });
  }

  Future<void> delete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(registrationPlateRepositoryProvider)
          .deleteRegistrationPlate(id);
      ref.invalidate(registrationPlatesProvider);
    });
  }
}
