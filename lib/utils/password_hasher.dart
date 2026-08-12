import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Local, non-networked credential hashing: a random salt plus a SHA-256
/// digest of salt+password. Accepted for a local single-device tool per
/// RESEARCH assumption A1 and D-05 (no backend, no JWT/OAuth in scope).
class PasswordHasher {
  PasswordHasher._();

  static const int _saltBytes = 16;

  /// Generates a fresh random salt using a cryptographically secure RNG
  /// (never the default, predictable `Random()`), encoded to a printable
  /// base64 string.
  static String generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(_saltBytes, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  /// Deterministically derives a hex digest from `salt + password`. Same
  /// inputs always produce the same output; different salts for the same
  /// password produce different outputs.
  static String hash(String password, String salt) {
    final bytes = utf8.encode(salt + password);
    return sha256.convert(bytes).toString();
  }

  /// Re-derives the hash from the supplied password and salt and compares
  /// it against the expected digest. Never decodes anything.
  static bool verify(String password, String salt, String expectedHash) {
    return hash(password, salt) == expectedHash;
  }
}
