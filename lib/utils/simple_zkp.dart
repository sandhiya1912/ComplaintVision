import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class SimpleZKP {
  static String generateNonce([int length = 16]) {
    final rand = Random.secure();
    final bytes = List<int>.generate(length, (_) => rand.nextInt(256));
    return base64Url.encode(bytes);
  }

  static String computeCommitment(String secret, String nonce) {
    final input = utf8.encode(secret + nonce);
    return sha256.convert(input).toString();
  }
}
