import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:calorietrack_flutter/infrastructure/security/pbkdf2_password_hasher.dart';

void main() {
  const hasher = Pbkdf2PasswordHasher();

  group('Pbkdf2PasswordHasher', () {
    test('verifies the correct password', () {
      final stored = hasher.hash('correct horse battery staple');
      expect(hasher.verify('correct horse battery staple', stored), isTrue);
    });

    test('rejects a wrong password', () {
      final stored = hasher.hash('correct horse battery staple');
      expect(hasher.verify('Correct horse battery staple', stored), isFalse);
      expect(hasher.verify('wrong', stored), isFalse);
    });

    test('uses a fresh salt so equal passwords hash differently', () {
      final a = hasher.hash('same-password');
      final b = hasher.hash('same-password');
      expect(a.salt, isNot(b.salt));
      expect(a.hash, isNot(b.hash));
      expect(hasher.verify('same-password', a), isTrue);
      expect(hasher.verify('same-password', b), isTrue);
    });

    test('stores a 16-byte salt and a 32-byte hash', () {
      final stored = hasher.hash('whatever');
      expect(base64Decode(stored.salt).length, 16);
      expect(base64Decode(stored.hash).length, 32);
    });

    test('handles an empty password without crashing', () {
      final stored = hasher.hash('');
      expect(hasher.verify('', stored), isTrue);
      expect(hasher.verify(' ', stored), isFalse);
    });
  });
}
