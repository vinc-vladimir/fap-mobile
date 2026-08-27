import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/account/presentation/screens/account_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/confirm_registration_screen.dart';
import '../../features/auth/presentation/screens/email_sent_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/privacy_policy_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/terms_of_service_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/settings/presentation/screens/change_password_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../widgets/main_shell.dart';
import '../widgets/screen_app_bar.dart';

/// Auth-required locations: while logged out these redirect to sign-in.
final _protectedLocations = <String>[
  '/',
  '/map',
  '/wallet',
  '/activity',
  '/account',
];

/// Auth locations: while logged in these redirect into the main shell.
///
/// Note: `/confirm-registration` is intentionally NOT here. It is a public,
/// token-driven action opened via a `fap://` deep link and must render whether
/// or not a (possibly stale) session exists — otherwise the guard redirects a
/// logged-in user to `/` and the confirm API call never fires. Password reset
/// (`/reset-password`) will follow the same rule.
const _authLocations = <String>[
  '/sign-in',
  '/sign-up',
  '/forgot-password',
  '/email-sent',
  '/privacy-policy',
  '/terms-of-service',
];

/// True if [location] equals [target] or starts with `target/` (so `/` matches
/// only the root and `/account` matches `/account/settings` but not `/accountX`).
bool _isAtOrUnder(String location, String target) {
  return location == target || location.startsWith('$target/');
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/sign-in',
    redirect: (context, state) {
      final loggedIn = ref.read(authStateProvider);
      final location = state.matchedLocation;

      final isProtected = _protectedLocations.any(
        (l) => _isAtOrUnder(location, l),
      );
      final isAuthRoute = _authLocations.any((l) => _isAtOrUnder(location, l));

      final result = (!loggedIn && isProtected)
          ? '/sign-in'
          : (loggedIn && isAuthRoute)
          ? '/'
          : null;
      debugPrint(
        '[RouterRedirect] loc=$location loggedIn=$loggedIn '
        'isProtected=$isProtected isAuthRoute=$isAuthRoute → $result',
      );

      return result;
    },
    routes: [
      // ── Auth flow (no shell) ────────────────────────────────────
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/email-sent',
        builder: (context, state) =>
            EmailSentScreen(description: state.extra as String?),
      ),
      GoRoute(
        path: '/confirm-registration/:token',
        builder: (context, state) => ConfirmRegistrationScreen(
          token: state.pathParameters['token'] ?? '',
        ),
      ),
      GoRoute(
        path: '/privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/terms-of-service',
        builder: (context, state) => const TermsOfServiceScreen(),
      ),

      // ── Main shell (5 tabs) ─────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(shell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                builder: (context, state) =>
                    const _PlaceholderTab(label: 'MAP'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/wallet',
                builder: (context, state) =>
                    const _PlaceholderTab(label: 'WALLET'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/activity',
                builder: (context, state) =>
                    const _PlaceholderTab(label: 'ACTIVITY'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/account',
                builder: (context, state) => const AccountScreen(),
                routes: [
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsScreen(),
                  ),
                  GoRoute(
                    path: 'change-password',
                    builder: (context, state) => const ChangePasswordScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  // Re-run redirects whenever the auth session changes (login, logout, and the
  // async cold-start restore of a persisted token) so the guard can navigate
  // the user into/out of the shell automatically.
  ref.listen(authStateProvider, (previous, next) => router.refresh());

  return router;
});

/// Disabled tab placeholder used for MAP / WALLET / ACTIVITY until those
/// screens are implemented.
class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          const ScreenAppBar(title: '', mode: ScreenAppBarMode.main),
          Expanded(
            child: Center(
              child: Text(
                label,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
