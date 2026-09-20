/// Lifecycle status of an organization invitation.
///
/// Mirrors the backend `OrganizationInvitationStatus` enum. [unknown] is a
/// defensive fallback for values the app does not recognise yet.
enum OrganizationInvitationStatus {
  pending('PENDING'),
  accepted('ACCEPTED'),
  revoked('REVOKED'),
  expired('EXPIRED'),
  unknown('');

  const OrganizationInvitationStatus(this.wireValue);

  final String wireValue;

  static OrganizationInvitationStatus fromWire(String? value) {
    return OrganizationInvitationStatus.values.firstWhere(
      (status) => status.wireValue == value,
      orElse: () => OrganizationInvitationStatus.unknown,
    );
  }

  bool get isPending => this == OrganizationInvitationStatus.pending;
}
