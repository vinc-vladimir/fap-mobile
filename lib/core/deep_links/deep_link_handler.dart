import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

/// Routes `fap://` deep links received from the platform (e.g. the
/// registration-confirm link embedded in the confirmation email) into the app.
class DeepLinkHandler {
  DeepLinkHandler._();

  static const String _registrationConfirmPath = 'registration-confirm';

  /// Converts a received URI into the equivalent in-app route, or returns null
  /// if the link is not recognized. The caller is responsible for invoking it
  /// on the router.
  static String? routeForUri(Uri uri) {
    // Custom scheme links (`fap://registration-confirm?token=...`) place the
    // route in the host; https links put it in the path.
    final path = uri.path.isEmpty ? uri.host : uri.path;
    final token = uri.queryParameters['token'];

    final route =
        (path.contains(_registrationConfirmPath) &&
            token != null &&
            token.isNotEmpty)
        ? '/confirm-registration/$token'
        : null;
    debugPrint(
      '[DeepLinkHandler] scheme=${uri.scheme} host=${uri.host} path=${uri.path} '
      'token=${token ?? "<none>"} → route=${route ?? "<unhandled>"}',
    );
    return route;
  }

  static void handleUri(GoRouter router, Uri uri) {
    final route = routeForUri(uri);
    if (route == null) return;
    debugPrint('[DeepLinkHandler] navigating to $route');
    // Use push (not go) so the confirm screen is stacked on the current route
    // rather than triggering the StatefulShellRoute redirect that hijacks `go`
    // to top-level routes while logged out.
    router.push(route);
  }
}
