import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final appTextTheme = GoogleFonts.interTextTheme(
  const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 40 / 32,
      letterSpacing: -0.02,
    ),
    displayMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 32 / 24,
      letterSpacing: -0.01,
    ),
    displaySmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 28 / 20,
    ),
    bodyLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      height: 28 / 18,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 24 / 16,
    ),
    bodySmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 20 / 14,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 16 / 12,
      letterSpacing: 0.05,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      height: 14 / 10,
    ),
  ),
);

const linkMedium = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w900,
  height: 20 / 14,
);

const linkSmall = TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.w900,
  height: 14 / 10,
);
