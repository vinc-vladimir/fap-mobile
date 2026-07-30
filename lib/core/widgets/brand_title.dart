import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class BrandTitle extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? fillColor;
  final double strokeWidth;

  const BrandTitle({
    super.key,
    required this.text,
    this.style,
    this.fillColor,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = style ?? Theme.of(context).textTheme.displayLarge;
    final fill = fillColor ?? vibrantCyan;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Text(
          text,
          style: textStyle?.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = brandPrimary,
          ),
        ),
        Text(text, style: textStyle?.copyWith(color: fill)),
      ],
    );
  }
}
