import 'package:flutter_test/flutter_test.dart';
import 'package:tecnoiso_demo/utils/password_hasher.dart';

void main() {
  group('PasswordHasher', () {
    test('generateSalt returns a non-empty string', () {
      final salt = PasswordHasher.generateSalt();
      expect(salt, isNotEmpty);
    });

    test('two consecutive generateSalt calls differ', () {
      final saltA = PasswordHasher.generateSalt();
      final saltB = PasswordHasher.generateSalt();
      expect(saltA, isNot(equals(saltB)));
    });

    test('hash is deterministic for the same password and salt', () {
      const password = 'correct horse battery staple';
      final salt = PasswordHasher.generateSalt();
      final hashA = PasswordHasher.hash(password, salt);
      final hashB = PasswordHasher.hash(password, salt);
      expect(hashA, equals(hashB));
    });

    test('same password with two different salts yields different digests',
        () {
      const password = 'correct horse battery staple';
      final saltA = PasswordHasher.generateSalt();
      final saltB = PasswordHasher.generateSalt();
      final hashA = PasswordHasher.hash(password, saltA);
      final hashB = PasswordHasher.hash(password, saltB);
      expect(hashA, isNot(equals(hashB)));
    });

    test('digest never contains the plaintext password as a substring', () {
      const password = 'super-secret-password-123';
      final salt = PasswordHasher.generateSalt();
      final hash = PasswordHasher.hash(password, salt);
      expect(hash.contains(password), isFalse);
    });

    test('verify is true for the correct password', () {
      const password = 'my-password';
      final salt = PasswordHasher.generateSalt();
      final hash = PasswordHasher.hash(password, salt);
      expect(PasswordHasher.verify(password, salt, hash), isTrue);
    });

    test('verify is false for a wrong password', () {
      const password = 'my-password';
      final salt = PasswordHasher.generateSalt();
      final hash = PasswordHasher.hash(password, salt);
      expect(PasswordHasher.verify('wrong-password', salt, hash), isFalse);
    });
  });
}
