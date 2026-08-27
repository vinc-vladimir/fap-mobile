import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_model.freezed.dart';
part 'account_model.g.dart';

@freezed
abstract class AccountModel with _$AccountModel {
  const factory AccountModel({
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'authUserId') String? authUserId,
    @JsonKey(name: 'firstName') String? firstName,
    @JsonKey(name: 'lastName') String? lastName,
    @JsonKey(name: 'phone') String? phone,
    @JsonKey(name: 'address') String? address,
    @JsonKey(name: 'city') String? city,
    @JsonKey(name: 'zip') String? zip,
    @JsonKey(name: 'country') String? country,
    @JsonKey(name: 'organizationId') String? organizationId,
    @JsonKey(name: 'createdAt') DateTime? createdAt,
    @JsonKey(name: 'passwordChangedAt') DateTime? passwordChangedAt,
  }) = _AccountModel;

  factory AccountModel.fromJson(Map<String, dynamic> json) =>
      _$AccountModelFromJson(json);
}
