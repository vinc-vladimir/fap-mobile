import 'package:flutter/material.dart';
import 'package:fap_mobile/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../account/presentation/screens/account_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [_buildContent(context), const _HomeBottomNav()]),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _HomeAppBar(l10n: l10n, theme: theme),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.marginMain,
              AppDimensions.stackLg,
              AppDimensions.marginMain,
              120,
            ),
            children: [
              _PointsCard(l10n: l10n, theme: theme),
              const SizedBox(height: AppDimensions.stackLg),
              _StationCard(l10n: l10n, theme: theme),
              const SizedBox(height: AppDimensions.stackLg),
              _RewardsSection(l10n: l10n, theme: theme),
            ],
          ),
        ),
      ],
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;

  const _HomeAppBar({required this.l10n, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 16,
        left: AppDimensions.marginMain + 4,
        right: AppDimensions.marginMain,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            l10n.homeTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications_outlined,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: AppDimensions.stackSm),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF00DCE5)
                    : brandPrimary,
                width: 2,
              ),
            ),
            child: const CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Icon(Icons.person, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

class _PointsCard extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;

  const _PointsCard({required this.l10n, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFF00DCE5) : vibrantCyan;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.containerPadding + 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xB31A2130) : surfaceGlassLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
        border: Border.all(
          color: isDark ? const Color(0x14FFFFFF) : glassBorderLight,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 192,
            height: 192,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(192, 192),
                  painter: _CircularProgressPainter(
                    progress: 0.7,
                    trackColor: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : brandPrimary.withValues(alpha: 0.1),
                    progressColor: accentColor,
                    strokeWidth: 8,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.pointsValue,
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      l10n.pointsLabel.toUpperCase(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: accentColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.stackMd),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.stackMd,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF273647)
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : glassBorderLight,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.workspace_premium,
                  size: 18,
                  color: isDark ? const Color(0xFFC0C6DA) : brandPrimary,
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.bronzeLevel.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    letterSpacing: 0.05,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.stackSm),
          Text(
            l10n.pointsUntilSilver('760'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StationCard extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;

  const _StationCard({required this.l10n, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFF00DCE5) : vibrantCyan;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.nearbyStation,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: Text(
                l10n.viewMap.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: accentColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.stackMd),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xB31A2130) : surfaceGlassLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
            border: Border.all(
              color: isDark ? const Color(0x14FFFFFF) : glassBorderLight,
            ),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radiusXxl),
                ),
                child: Container(
                  height: 160,
                  color: isDark ? const Color(0xFF0d1c2d) : mapVoid,
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.local_gas_station,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      Positioned(
                        top: AppDimensions.stackMd,
                        left: AppDimensions.stackMd,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.stackSm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF273647).withValues(alpha: 0.9)
                                : surfaceGlassLight,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusLg,
                            ),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : glassBorderLight,
                            ),
                          ),
                          child: Text(
                            l10n.distanceAway('0.8'),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: accentColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(
                  AppDimensions.containerPadding + 4,
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.omvStationName,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                l10n.omvStationAddress,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusXl,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withValues(alpha: 0.3),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.directions),
                            color: theme.brightness == Brightness.dark
                                ? const Color(0xFF051424)
                                : brandPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.stackMd),
                    Row(
                      children: [
                        _FuelChip(
                          label: l10n.fuelSuper95,
                          price: '€1.649',
                          theme: theme,
                        ),
                        const SizedBox(width: AppDimensions.stackSm),
                        _FuelChip(
                          label: l10n.fuelDiesel,
                          price: '€1.598',
                          theme: theme,
                        ),
                        const SizedBox(width: AppDimensions.stackSm),
                        _FuelChip(
                          label: l10n.fuelUltimate100,
                          price: '€1.824',
                          theme: theme,
                          isHighlighted: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.stackMd),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.white,
                          foregroundColor: theme.colorScheme.onSurface,
                          side: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : glassBorderLight,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusXl,
                            ),
                          ),
                        ),
                        child: Text(
                          l10n.navigate.toUpperCase(),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FuelChip extends StatelessWidget {
  final String label;
  final String price;
  final ThemeData theme;
  final bool isHighlighted;

  const _FuelChip({
    required this.label,
    required this.price,
    required this.theme,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFF00DCE5) : vibrantCyan;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.stackSm,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF122131)
              : theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : glassBorderLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              price,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isHighlighted
                    ? accentColor
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardsSection extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;

  const _RewardsSection({required this.l10n, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFF00DCE5) : vibrantCyan;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.myRewards,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: Text(
                l10n.seeAll.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: accentColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.stackMd),
        SizedBox(
          height: 240,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _RewardCard(
                title: l10n.percentOffPremium,
                subtitle: l10n.discountValidUntil('Oct 24, 2023'),
                actionLabel: l10n.redeemPoints,
                isNew: true,
                theme: theme,
              ),
              const SizedBox(width: AppDimensions.stackMd),
              _RewardCard(
                title: l10n.freeDeluxeWash,
                subtitle: l10n.afterRefuels('5'),
                showProgress: true,
                theme: theme,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RewardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actionLabel;
  final bool isNew;
  final bool showProgress;
  final ThemeData theme;

  const _RewardCard({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.isNew = false,
    this.showProgress = false,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFF00DCE5) : vibrantCyan;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xB31A2130) : surfaceGlassLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
        border: Border.all(
          color: isDark ? const Color(0x14FFFFFF) : glassBorderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusXxl),
            ),
            child: Container(
              height: 128,
              color: isDark ? const Color(0xFF0d1c2d) : mapVoid,
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      isNew ? Icons.local_offer : Icons.local_car_wash,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                  if (isNew)
                    Positioned(
                      top: AppDimensions.stackMd,
                      right: AppDimensions.stackMd,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.stackSm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusSm,
                          ),
                        ),
                        child: Text(
                          l10n.newBadge.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.brightness == Brightness.dark
                                ? const Color(0xFF003739)
                                : brandPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.containerPadding + 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: 18,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (actionLabel != null) ...[
                  const SizedBox(height: AppDimensions.stackSm),
                  Row(
                    children: [
                      Icon(
                        Icons.confirmation_number,
                        size: 18,
                        color: accentColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        actionLabel!.toUpperCase(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ],
                if (showProgress) ...[
                  const SizedBox(height: AppDimensions.stackSm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusFull,
                    ),
                    child: LinearProgressIndicator(
                      value: 0.6,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : brandPrimary.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                      minHeight: 6,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeBottomNav extends StatelessWidget {
  const _HomeBottomNav();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFF00DCE5) : vibrantCyan;
    final l10n = AppLocalizations.of(context)!;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          left: AppDimensions.stackMd,
          right: AppDimensions.stackMd,
          top: AppDimensions.stackSm + 4,
          bottom: MediaQuery.of(context).padding.bottom + AppDimensions.stackSm,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.8),
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : glassBorderLight,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home,
              label: l10n.bottomNavHome,
              isActive: true,
              accentColor: accentColor,
              isDark: isDark,
              theme: theme,
            ),
            _NavItem(
              icon: Icons.local_gas_station_outlined,
              label: l10n.bottomNavRefuel,
              accentColor: accentColor,
              isDark: isDark,
              theme: theme,
            ),
            _NavItem(
              icon: Icons.history,
              label: l10n.bottomNavActivity,
              accentColor: accentColor,
              isDark: isDark,
              theme: theme,
            ),
            _NavItem(
              icon: Icons.person_outline,
              label: l10n.bottomNavAccount,
              accentColor: accentColor,
              isDark: isDark,
              theme: theme,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccountScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color accentColor;
  final bool isDark;
  final ThemeData theme;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.accentColor,
    required this.isDark,
    required this.theme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.containerPadding,
          vertical: AppDimensions.stackSm,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? accentColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? accentColor
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                fontSize: 10,
                color: isActive
                    ? accentColor
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final sweepAngle = 2 * 3.141592653589793 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.141592653589793 / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
