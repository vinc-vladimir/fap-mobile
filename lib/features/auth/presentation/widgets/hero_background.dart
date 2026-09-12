import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HeroBackground extends StatelessWidget {
  const HeroBackground({super.key, this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.40,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            imagePath ?? 'assets/images/sports_car_refueling.png',
            fit: BoxFit.cover,
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    scrimBlack50,
                    Colors.transparent,
                    theme.colorScheme.surface,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
