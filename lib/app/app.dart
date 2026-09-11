import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

import '../core/deep_links/deep_link_handler.dart';
import '../core/l10n/locale_provider.dart';
import '../core/network/health_providers.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_provider.dart';
import '../features/auth/presentation/screens/confirm_registration_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';

/// MaterialApp wired to go_router and the theme/locale providers.
class FapApp extends ConsumerStatefulWidget {
  const FapApp({super.key});

  @override
  ConsumerState<FapApp> createState() => _FapAppState();
}

class _FapAppState extends ConsumerState<FapApp> {
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    final appLinks = AppLinks();
    final router = ref.read(routerProvider);

    // Handle a deep link that launched a cold-started app.
    final initialUri = await appLinks.getInitialLink();
    if (initialUri != null) {
      debugPrint('[DeepLink] cold-start initial link: $initialUri');
      _handleDeepLink(router, initialUri);
    } else {
      debugPrint('[DeepLink] no initial link on cold start');
    }

    // Handle deep links received while the app is already running.
    _linkSubscription = appLinks.uriLinkStream.listen(
      (uri) {
        debugPrint('[DeepLink] warm-start stream link: $uri');
        _handleDeepLink(router, uri);
      },
      onError: (Object e) {
        debugPrint('[DeepLink] stream error: $e');
      },
    );
  }

  /// Routes a received deep link into the app.
  ///
  /// Email confirmation and password-reset links are presented directly on the
  /// navigator (not via go_router) because go_router's `redirect` re-evaluates
  /// the `StatefulShellRoute` home `/` while navigating to a top-level route when
  /// logged out, hijacking the screen with a `/sign-in` redirect. Pushing the
  /// screen directly bypasses that redirect entirely.
  void _handleDeepLink(GoRouter router, Uri uri) {
    final route = DeepLinkHandler.routeForUri(uri);
    if (route == null) return;

    final token = uri.queryParameters['token'];
    if (token != null && token.isNotEmpty) {
      final WidgetBuilder? builder;
      if (route.startsWith('/confirm-registration')) {
        builder = (_) => ConfirmRegistrationScreen(token: token);
      } else if (route.startsWith('/reset-password')) {
        builder = (_) => ResetPasswordScreen(token: token);
      } else {
        builder = null;
      }

      if (builder != null) {
        final navigator = router.routerDelegate.navigatorKey.currentState;
        if (navigator != null) {
          debugPrint('[DeepLink] presenting screen for route=$route');
          navigator.push(MaterialPageRoute<void>(builder: builder));
          return;
        }
      }
    }

    DeepLinkHandler.handleUri(router, uri);
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Kick off the background fap-service health check on app startup.
    ref.listen(serverStatusControllerProvider, (_, _) {});

    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      routerConfig: router,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
