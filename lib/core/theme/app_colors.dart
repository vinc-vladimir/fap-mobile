import 'package:flutter/material.dart';

// ── Custom brand colors ──────────────────────────────────────────
const vibrantCyan = Color(0xFF00F5FF);
const surfaceGlassLight = Color(0xD9FFFFFF); // rgba(255,255,255,0.85)
const surfaceGlassDark = Color(0xB31A2130);  // rgba(26,33,48,0.7)
const successGlint = Color(0xFF97E5EB);
const mapVoid = Color(0xFFECEEF0);

// ── Light ColorScheme — Velocity Flux ────────────────────────────
const lightColorScheme = ColorScheme(
  brightness: Brightness.light,

  primary: Color(0xFF00696E),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF00F5FF),
  onPrimaryContainer: Color(0xFF006C71),

  secondary: Color(0xFF565E74),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFDAE2FD),
  onSecondaryContainer: Color(0xFF5C647A),

  tertiary: Color(0xFF505F76),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFCEDFF9),
  onTertiaryContainer: Color(0xFF536279),

  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF93000A),

  surface: Color(0xFFF7F9FB),
  onSurface: Color(0xFF191C1E),
  onSurfaceVariant: Color(0xFF3A494A),

  outline: Color(0xFF6A7A7B),
  outlineVariant: Color(0xFFB9CACA),

  inverseSurface: Color(0xFF2D3133),
  onInverseSurface: Color(0xFFEFF1F3),
  inversePrimary: Color(0xFF93D1D5),

  surfaceTint: Color(0xFF27676B),
);

// ── Dark ColorScheme — Velocity Blue ──────────────────────────────
const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,

  primary: Color(0xFFE9FEFF),
  onPrimary: Color(0xFF003739),
  primaryContainer: Color(0xFF00F5FF),
  onPrimaryContainer: Color(0xFF006C71),

  secondary: Color(0xFFC0C6DA),
  onSecondary: Color(0xFF293040),
  secondaryContainer: Color(0xFF42495A),
  onSecondaryContainer: Color(0xFFB1B8CC),

  tertiary: Color(0xFFFAF9FF),
  onTertiary: Color(0xFF2C303B),
  tertiaryContainer: Color(0xFFD9DDEC),
  onTertiaryContainer: Color(0xFF5C616E),

  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),

  surface: Color(0xFF051424),
  onSurface: Color(0xFFD4E4FA),
  onSurfaceVariant: Color(0xFFB9CACA),

  outline: Color(0xFF849495),
  outlineVariant: Color(0xFF3A494A),

  inverseSurface: Color(0xFFD4E4FA),
  onInverseSurface: Color(0xFF233143),
  inversePrimary: Color(0xFF00696E),

  surfaceTint: Color(0xFF00DCE5),
);
