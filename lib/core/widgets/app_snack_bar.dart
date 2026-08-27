import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Shows a theme-adaptive SnackBar for success or error feedback.
///
/// Uses the `ColorScheme` error containers and the custom success container
/// tokens from `app_colors.dart`, so colors adapt to the current light/dark
/// theme and always meet on-color contrast. Call sites should use this instead
/// of constructing bare `SnackBar`s directly.
void showAppSnackBar(
  ScaffoldMessengerState messenger, {
  required String message,
  bool isError = false,
}) {
  final theme = Theme.of(messenger.context);
  final isDark = theme.brightness == Brightness.dark;
  final scheme = theme.colorScheme;

  final backgroundColor = isError
      ? scheme.errorContainer
      : (isDark ? successContainerDark : successContainerLight);
  final contentColor = isError
      ? scheme.onErrorContainer
      : (isDark ? onSuccessContainerDark : onSuccessContainerLight);

  messenger.showSnackBar(
    SnackBar(
      content: Text(message, style: TextStyle(color: contentColor)),
      backgroundColor: backgroundColor,
    ),
  );
}
