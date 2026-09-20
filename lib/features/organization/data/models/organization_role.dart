/// Role of an account within an organization.
///
/// Mirrors the backend `OrganizationRole` enum. [unknown] is a defensive
/// fallback for values the app does not recognise yet.
enum OrganizationRole {
  orgOwner('ORG_OWNER'),
  orgMember('ORG_MEMBER'),
  unknown('');

  const OrganizationRole(this.wireValue);

  final String wireValue;

  static OrganizationRole fromWire(String? value) {
    return OrganizationRole.values.firstWhere(
      (role) => role.wireValue == value,
      orElse: () => OrganizationRole.unknown,
    );
  }

  bool get isOwner => this == OrganizationRole.orgOwner;
}
