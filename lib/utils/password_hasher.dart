import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class PasswordHasher {
  static const int _saltLength = 16;

  const PasswordHasher();

  String generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(_saltLength, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }

  String hash(String password, String salt) {
    final bytes = utf8.encode('$salt:$password');
    return base64Encode(sha256.convert(bytes).bytes);
  }

  bool verify(String password, String salt, String expectedHash) {
    return hash(password, salt) == expectedHash;
  }
}
