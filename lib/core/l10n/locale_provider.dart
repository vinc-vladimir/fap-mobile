import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Client-side locale preference for the app (English / Srpski).
///
/// Note: the fap-service has no user-preference endpoint for language (the
/// backend only carries an email-localization field), so the choice is stored
/// locally via this provider.
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => const Locale('en');

  void setLocale(Locale locale) => state = locale;
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
