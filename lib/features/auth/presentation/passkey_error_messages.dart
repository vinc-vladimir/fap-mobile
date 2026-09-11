import '../../../l10n/app_localizations.dart';
import '../data/services/passkey_service.dart';

/// Localized message for a passkey failure. Returns an empty string for
/// cancellations so callers can stay silent.
String passkeyErrorMessage(AppLocalizations l10n, Object? error) {
  if (error is PasskeyException) {
    return switch (error.failure) {
      PasskeyFailure.cancelled => '',
      PasskeyFailure.noCredentials => l10n.passkeyErrorNoCredentials,
      PasskeyFailure.googleSignInRequired => l10n.passkeyErrorGoogleSignIn,
      PasskeyFailure.domainNotAssociated =>
        l10n.passkeyErrorDomainNotAssociated,
      PasskeyFailure.noCreateOption => l10n.passkeyErrorNoCreateOption,
      PasskeyFailure.deviceUnsupported => l10n.passkeyErrorDeviceUnsupported,
      PasskeyFailure.syncUnavailable => l10n.passkeyErrorSyncUnavailable,
      PasskeyFailure.credentialAlreadyExists =>
        l10n.passkeyErrorCredentialExists,
      PasskeyFailure.malformedChallenge => l10n.passkeyErrorMalformedChallenge,
      PasskeyFailure.timeout => l10n.passkeyErrorTimeout,
      PasskeyFailure.unhandled => l10n.passkeyErrorUnhandled,
    };
  }
  return l10n.passkeyErrorGeneric;
}

/// Whether [error] represents a user cancellation of the passkey ceremony.
bool isPasskeyCancellation(Object? error) =>
    error is PasskeyException && error.isCancellation;
