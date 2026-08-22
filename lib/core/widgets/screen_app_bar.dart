import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// Top app bar used across the main shell and pushed sub-screens.
///
/// - [ScreenAppBarMode.main]: label aligned to the left (used on the five main
///   shell tabs, e.g. HOME / ACCOUNT).
/// - [ScreenAppBarMode.sub]: a back arrow on the left and the label centered
///   (used on pushed sub-screens, e.g. Settings opened from Account).
enum ScreenAppBarMode { main, sub }

class ScreenAppBar extends StatelessWidget {
  const ScreenAppBar({
    super.key,
    required this.title,
    this.mode = ScreenAppBarMode.main,
    this.trailing,
  });

  final String title;
  final ScreenAppBarMode mode;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFF00DCE5) : vibrantCyan;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 16,
        left: AppDimensions.marginMain,
        right: AppDimensions.marginMain,
      ),
      child: switch (mode) {
        ScreenAppBarMode.main => Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
        ScreenAppBarMode.sub => Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => context.pop(),
                icon: Icon(Icons.arrow_back, color: accentColor),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              ),
            ),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (trailing != null)
              Align(alignment: Alignment.centerRight, child: trailing!),
          ],
        ),
      },
    );
  }
}
