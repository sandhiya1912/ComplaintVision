import 'dart:convert';
import 'package:crypto/crypto.dart';

class HashUtils {
  static String getUserHash(String uid) {
    const salt = "YourAppSecretSalt123";
    return sha256.convert(utf8.encode(uid + salt)).toString();
  }
}
