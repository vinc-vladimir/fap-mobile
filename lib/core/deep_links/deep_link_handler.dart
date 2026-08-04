import 'package:flutter/material.dart';

import '../../features/auth/presentation/screens/confirm_registration_screen.dart';

/// Routes `fap://` deep links received from the platform (e.g. the
/// registration-confirm link embedded in the confirmation email) into the app.
class DeepLinkHandler {
  DeepLinkHandler._();

  /// Global navigator key wired to [MaterialApp.navigatorKey] so links can be
  /// handled from outside the widget tree.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String _registrationConfirmPath = 'registration-confirm';

  static void handleUri(Uri uri) {
    // Custom scheme links (`fap://registration-confirm?token=...`) place the
    // route in the host; https links put it in the path.
    final path = uri.path.isEmpty ? uri.host : uri.path;
    final token = uri.queryParameters['token'];
    final navigator = navigatorKey.currentState;
    if (navigator == null || token == null || token.isEmpty) return;

    if (path.contains(_registrationConfirmPath)) {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => ConfirmRegistrationScreen(token: token),
        ),
        (route) => route.isFirst,
      );
    }
  }
}
