# Initial Design System Setup — Lessons Learned

## Overview

This phase established the foundational design system for FAP Mobile by translating
the Velocity Flux (light) / Velocity Blue (dark) design tokens into Flutter/Material 3
theme files. The `design/` folder is the single source of truth for design specs;
the `lib/core/theme/` folder is the compiled Dart implementation.

---

## Files Created

| File | Purpose |
|---|---|
| `lib/core/theme/app_colors.dart` | Light + dark `ColorScheme` constants and custom brand colors (`vibrantCyan`, `surfaceGlassLight/Dark`, `successGlint`, `mapVoid`) |
| `lib/core/theme/app_typography.dart` | `TextTheme` with all 8 Inter-based text styles (headline-lg → displayLarge, body-md → bodyMedium, label-md → labelMedium, etc.) |
| `lib/core/theme/app_dimensions.dart` | Spacing (`stackSm` 8, `stackMd` 16, `stackLg` 24, `marginMain` 20) and border radius (`radiusSm` 4 → `radiusFull` 9999) constants |
| `lib/core/theme/app_theme.dart` | `lightTheme` and `darkTheme` getters that compose `ColorScheme` + `TextTheme` + `InputDecorationTheme` + `ElevatedButtonTheme` + `OutlinedButtonTheme` |
| `lib/core/theme/theme_provider.dart` | `NotifierProvider<ThemeModeNotifier, ThemeMode>` so the app can toggle/system-follow theme |
| `lib/main.dart` | Entrypoint with `ProviderScope` + `FapApp` (ConsumerWidget) using `MaterialApp(theme:, darkTheme:, themeMode:)` |
| `assets/images/` | `google_logo.png`, `github_logo.png`, `sports_car_refueling.png` copied from `design/sign_in/images/` |

---

## Key Decisions

### 1. Explicit ColorScheme vs ColorScheme.fromSeed
The design has specific hex values for every M3 surface container level. We used the
**explicit `const ColorScheme(...)` constructor** with all tokens from the DESIGN.md
and code.html tailwind configs to match exactly. `ColorScheme.fromSeed` would not
reproduce the custom surface container hierarchy.

### 2. NotifierProvider instead of StateProvider for theme mode
Riverpod 3.x removed `StateProvider`. We use `NotifierProvider<ThemeModeNotifier, ThemeMode>`
which is the Riverpod 3.x idiomatic way to manage simple mutable state.

### 3. Inter font not bundled
The `TextTheme` specifies `fontFamily: 'Inter'`. For the font to actually render:
- **Recommended:** Add `google_fonts: ^6.0.0` dependency and use `GoogleFonts.interTextTheme()`
- **Alternative:** Download Inter .ttf files into `fonts/` and declare in `pubspec.yaml`
- Until then, the system fallback font is used (build compiles fine)

### 4. Asset strategy
Images are placed flat in `assets/images/` rather than per-feature. This avoids
duplication (e.g., `sports_car_refueling.png` appears in both auth screens and future
splash/onboarding screens). The `design/` folder mirrors this structure for authoring.

### 5. UI theme vs component theme
`app_theme.dart` sets input decoration, button, and scaffold defaults via `ThemeData`.
Per-screen custom overrides (e.g., glass card effect, hero background) are deliberately
NOT in the global theme — they belong in the screen widgets themselves.

---

## Design Token → Flutter Mapping

| DESIGN.md YAML | Flutter File | Dart Name |
|---|---|---|
| `colors.primary` | `app_colors.dart` | `lightColorScheme.primary` / `darkColorScheme.primary` |
| `colors.primary-container` | `app_colors.dart` | `lightColorScheme.primaryContainer` / `darkColorScheme.primaryContainer` |
| `colors.vibrant-cyan` | `app_colors.dart` | `vibrantCyan` (top-level const) |
| `typography.headline-lg` | `app_typography.dart` | `appTextTheme.displayLarge` |
| `typography.body-md` | `app_typography.dart` | `appTextTheme.bodyMedium` |
| `rounded.md` (0.75rem) | `app_dimensions.dart` | `AppDimensions.radiusLg` (12px) |
| `spacing.stack-md` (16px) | `app_dimensions.dart` | `AppDimensions.stackMd` (16px) |
| `colors.surface-glass` | `app_colors.dart` | `surfaceGlassLight` / `surfaceGlassDark` |

---

## Guidelines for Sign In / Sign Up Screens

### 1. Hero Background
Both light and dark code.html use a full-width image covering 35–40vh of the viewport
with a gradient overlay fading into the surface color. In Flutter:
- Use `Stack` with a positioned `Image.asset('assets/images/sports_car_refueling.png')`
- Overlay with `Container` + `BoxDecoration(gradient: LinearGradient(...))` using `Theme.of(context).colorScheme.surface`

### 2. Glass Card
The sign-in form lives in a "glass card":
```dart
Container(
  decoration: BoxDecoration(
    color: isLight ? surfaceGlassLight : surfaceGlassDark,
    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
    border: Border.all(color: isLight ? Color(0x1A00696E) : Color(0x14FFFFFF)),
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Padding(...),
    ),
  ),
)
```

### 3. Input Fields
Use `Theme.of(context).inputDecorationTheme` as base, but override for the leading icon:
- 12px left padding extra for the icon
- Icon color: `outline` → `vibrantCyan` on focus
- Use `TextFormField` with `decoration: InputDecoration(prefixIcon: Icon(...))`

### 4. Buttons
**Primary (SIGN IN / SIGN UP):** Use `ElevatedButton` with `styleFrom(backgroundColor: vibrantCyan)`.
Add `scale(0.98)` on press via `GestureRecognizer` or `InkWell` wrapper.

**Biometric:** Use `OutlinedButton` with fingerprint icon.

**Social (Google/GitHub):** Use `OutlinedButton` in a 2-column `Row`/`GridView`, each with
brand logo + uppercase label.

### 5. Divider
```
OR CONTINUE WITH
```
Implement as `Row` with two `Expanded` dividers and a center `Text`:
```dart
Row(
  children: [
    Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
    Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.stackMd),
      child: Text('OR CONTINUE WITH', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.outline)),
    ),
    Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
  ],
)
```

### 6. Bottom Links
"Don't have an account? Sign up now" + "Privacy Policy | Terms of Service".
Position at bottom of screen using `Column(mainAxisAlignment: MainAxisAlignment.spaceBetween)` or
`Spacer` before the footer.

### 7. Sign Up Specifics
- Same hero + glass card layout as Sign In
- Three inputs: Email, Password, Confirm Password
- Replace biometric + social buttons with just the primary "SIGN UP" button
- "I'm already a member Sign In?" link instead of "Don't have an account"

### 8. No go_router yet
The current app uses `MaterialApp(home:)` directly. When we add routing for Sign In
→ Sign Up → Forgot Password etc., wrap with `MaterialApp.router` and define routes,
passing `AuthGuard` redirect logic.

---

## Verification Commands

```bash
flutter analyze        # Zero errors
flutter test           # All tests passing
```
