import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

import '../../../../core/storage/secure_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/brand_title.dart';
import '../passkey_error_messages.dart';
import '../providers/auth_providers.dart';
import '../providers/passkey_providers.dart';
import '../widgets/glass_card.dart';
import '../widgets/hero_background.dart';

/// Shown when a valid session is restored at cold start but a passkey is
/// registered for the account (P1-8). Prompts for a biometric scan; on success
/// `authState` flips to [AuthStatus.loggedIn] and the router redirects to `/`.
class BiometricGateScreen extends ConsumerStatefulWidget {
  const BiometricGateScreen({super.key});

  @override
  ConsumerState<BiometricGateScreen> createState() =>
      _BiometricGateScreenState();
}

class _BiometricGateScreenState extends ConsumerState<BiometricGateScreen> {
  bool _autoTriggered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fire the biometric prompt as soon as the gate is shown.
    if (!_autoTriggered) {
      _autoTriggered = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
    }
  }

  Future<void> _unlock() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;

    await ref.read(passkeyLoginControllerProvider.notifier).loginWithPasskey();
    if (!mounted) return;

    final state = ref.read(passkeyLoginControllerProvider);
    if (state.hasError) {
      final error = state.error;
      if (isPasskeyCancellation(error)) return;
      showAppSnackBar(
        messenger,
        message: passkeyErrorMessage(l10n, error),
        isError: true,
      );
      return;
    }
    // Success: authState becomes loggedIn and the router redirects to '/'.
  }

  /// Fallback: drop the session and let the user sign in with a password.
  Future<void> _usePassword() async {
    final storage = ref.read(secureStorageProvider);
    await storage.clearTokens();
    ref.read(authStateProvider.notifier).setAuthenticated(false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isLoading = ref.watch(passkeyLoginControllerProvider).isLoading;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          const HeroBackground(),
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: screenHeight * 0.28,
              left: AppDimensions.marginMain,
              right: AppDimensions.marginMain,
              bottom: AppDimensions.stackLg + bottomInset,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BrandTitle(text: l10n.fuelAutoPay),
                const SizedBox(height: AppDimensions.stackLg),
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(
                      AppDimensions.containerPadding,
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.fingerprint, size: 56, color: vibrantCyan),
                        const SizedBox(height: AppDimensions.stackMd),
                        Text(
                          l10n.biometricGateTitle,
                          style: theme.textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.stackSm),
                        Text(
                          l10n.biometricGateSubtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.stackLg),
                        ElevatedButton(
                          onPressed: isLoading ? null : _unlock,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: vibrantCyan,
                            foregroundColor: brandPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusLg,
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: brandPrimary,
                                  ),
                                )
                              : Text(
                                  l10n.biometricUnlock,
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    color: brandPrimary,
                                  ),
                                ),
                        ),
                        const SizedBox(height: AppDimensions.stackSm),
                        TextButton(
                          onPressed: _usePassword,
                          child: Text(
                            l10n.biometricGateUsePassword,
                            style: linkMedium.copyWith(color: vibrantCyan),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
