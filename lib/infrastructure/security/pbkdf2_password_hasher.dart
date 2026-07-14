import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../../domain/shared/hashed_password.dart';
import '../../domain/shared/password_hasher.dart';

class Pbkdf2PasswordHasher implements PasswordHasher {
  const Pbkdf2PasswordHasher();

  static const int _saltLength = 16;
  static const int _iterations = 120000;
  static const int _keyLength = 32;
  static const int _blockSize = 32;

  @override
  HashedPassword hash(String rawPassword) {
    final salt = _generateSalt();
    final derived = _deriveKey(rawPassword, salt);
    return HashedPassword(
      salt: base64Encode(salt),
      hash: base64Encode(derived),
    );
  }

  @override
  bool verify(String rawPassword, HashedPassword stored) {
    final salt = base64Decode(stored.salt);
    final expected = base64Decode(stored.hash);
    final actual = _deriveKey(rawPassword, salt);
    return _constantTimeEquals(expected, actual);
  }

  List<int> _generateSalt() {
    final random = Random.secure();
    return List<int>.generate(_saltLength, (_) => random.nextInt(256));
  }

  Uint8List _deriveKey(String password, List<int> salt) {
    final hmac = Hmac(sha256, utf8.encode(password));
    final blocks = (_keyLength / _blockSize).ceil();
    final output = <int>[];
    for (var block = 1; block <= blocks; block++) {
      output.addAll(_deriveBlock(hmac, salt, block));
    }
    return Uint8List.fromList(output.sublist(0, _keyLength));
  }

  List<int> _deriveBlock(Hmac hmac, List<int> salt, int block) {
    var u = hmac.convert([...salt, ..._blockIndex(block)]).bytes;
    final result = List<int>.from(u);
    for (var iteration = 1; iteration < _iterations; iteration++) {
      u = hmac.convert(u).bytes;
      for (var i = 0; i < result.length; i++) {
        result[i] ^= u[i];
      }
    }
    return result;
  }

  List<int> _blockIndex(int value) => [
        (value >> 24) & 0xff,
        (value >> 16) & 0xff,
        (value >> 8) & 0xff,
        value & 0xff,
      ];

  bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var difference = 0;
    for (var i = 0; i < a.length; i++) {
      difference |= a[i] ^ b[i];
    }
    return difference == 0;
  }
}
