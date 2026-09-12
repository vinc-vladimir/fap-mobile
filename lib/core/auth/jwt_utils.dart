import 'dart:convert';

/// Returns the JWT `sub` claim (the user's email for FAP tokens), or null if
/// the token is missing or malformed.
///
/// Decode-only: the signature is not verified (the client holds no signing
/// key). Claims read this way are trusted solely for non-security UI display;
/// the server remains the enforcement point.
String? emailFromJwt(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return null;
  try {
    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    );
    if (payload is! Map<String, dynamic>) return null;
    final sub = payload['sub'];
    return (sub is String && sub.isNotEmpty) ? sub : null;
  } catch (_) {
    return null;
  }
}
