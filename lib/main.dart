import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

import 'core/deep_links/deep_link_handler.dart';
import 'core/network/health_providers.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/presentation/screens/sign_in_screen.dart';

void main() {
  runApp(const ProviderScope(child: FapApp()));
}

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

    // Handle a deep link that launched a cold-started app.
    final initialUri = await appLinks.getInitialLink();
    if (initialUri != null) {
      DeepLinkHandler.handleUri(initialUri);
    }

    // Handle deep links received while the app is already running.
    _linkSubscription = appLinks.uriLinkStream.listen(
      DeepLinkHandler.handleUri,
    );
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Kick off the background fap-service health check on app startup.
    // Failures are logged to the console only; no UI is shown.
    ref.listen(serverStatusControllerProvider, (_, _) {});

    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      navigatorKey: DeepLinkHandler.navigatorKey,
      // locale: const Locale('sr'),
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SignInScreen(),
    );
  }
}
