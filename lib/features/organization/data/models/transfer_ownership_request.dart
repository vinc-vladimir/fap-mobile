import 'package:freezed_annotation/freezed_annotation.dart';

part 'transfer_ownership_request.freezed.dart';
part 'transfer_ownership_request.g.dart';

/// Body for `POST /v1/organizations/{id}/transfer-ownership`.
@freezed
abstract class TransferOwnershipRequest with _$TransferOwnershipRequest {
  const factory TransferOwnershipRequest({
    @JsonKey(name: 'memberId') required String memberId,
  }) = _TransferOwnershipRequest;

  factory TransferOwnershipRequest.fromJson(Map<String, dynamic> json) =>
      _$TransferOwnershipRequestFromJson(json);
}
