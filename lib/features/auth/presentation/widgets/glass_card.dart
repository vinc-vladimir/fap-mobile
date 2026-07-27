import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isLight ? surfaceGlassLight : surfaceGlassDark,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(
              color: isLight ? glassBorderLight : glassBorderDark,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.containerPadding),
            child: child,
          ),
        ),
      ),
    );
  }
}
