import 'package:flutter_test/flutter_test.dart';

import 'package:fap_mobile/core/deep_links/deep_link_handler.dart';

void main() {
  test('maps the https org-invitation App Link', () {
    final uri = Uri.parse('https://dev.fap.rs/org-invitation?token=abc123');
    expect(DeepLinkHandler.routeForUri(uri), '/org-invitation/abc123');
  });

  test('maps the fap:// org-invitation custom scheme', () {
    final uri = Uri.parse('fap://org-invitation?token=abc123');
    expect(DeepLinkHandler.routeForUri(uri), '/org-invitation/abc123');
  });

  test('still maps registration-confirm and reset links', () {
    expect(
      DeepLinkHandler.routeForUri(
        Uri.parse('https://dev.fap.rs/registration-confirm?token=t1'),
      ),
      '/confirm-registration/t1',
    );
    expect(
      DeepLinkHandler.routeForUri(
        Uri.parse('https://dev.fap.rs/set-new-password?token=t2'),
      ),
      '/reset-password/t2',
    );
  });

  test('returns null for unknown or tokenless links', () {
    expect(
      DeepLinkHandler.routeForUri(
        Uri.parse('https://dev.fap.rs/unknown?token=t'),
      ),
      isNull,
    );
    expect(
      DeepLinkHandler.routeForUri(
        Uri.parse('https://dev.fap.rs/org-invitation'),
      ),
      isNull,
    );
  });
}
