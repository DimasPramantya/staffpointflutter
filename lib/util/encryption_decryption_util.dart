import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';

class AESGCMEncryptor {
  final String secret;
  final String salt;
  final String ivStr;
  final int iterations;
  final int keyLength;

  AESGCMEncryptor({
    required this.secret,
    required this.salt,
    this.ivStr = '0000000000000000',
    this.iterations = 1000,
    this.keyLength = 32,
  });

  Uint8List _deriveKey() {
    final key = pbkdf2(
      password: secret,
      salt: salt,
      iterations: iterations,
      keyLength: keyLength,
    );
    return Uint8List.fromList(key);
  }

  List<int> pbkdf2({
    required String password,
    required String salt,
    required int iterations,
    required int keyLength,
  }) {
    final hmac = Hmac(sha256, utf8.encode(password));
    final saltBytes = utf8.encode(salt);

    int blockCount = (keyLength + hmac.convert([]).bytes.length - 1) ~/
        hmac.convert([]).bytes.length;

    List<int> derivedKey = [];

    for (int blockIndex = 1; blockIndex <= blockCount; blockIndex++) {
      List<int> blockData = List.from(saltBytes)
        ..addAll([
          (blockIndex >> 24) & 0xff,
          (blockIndex >> 16) & 0xff,
          (blockIndex >> 8) & 0xff,
          blockIndex & 0xff
        ]);

      var u = hmac.convert(blockData).bytes;
      var output = List<int>.from(u);

      for (int i = 1; i < iterations; i++) {
        u = hmac.convert(u).bytes;
        for (int j = 0; j < output.length; j++) {
          output[j] ^= u[j];
        }
      }

      derivedKey.addAll(output);
    }

    return derivedKey.sublist(0, keyLength);
  }

  String encrypt(String plainText) {
    final key = _deriveKey();
    final iv = IV.fromUtf8(ivStr);

    final encrypter = Encrypter(AES(Key(key), mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    return encrypted.base64;
  }

  String decrypt(String cipherTextBase64) {
    final key = _deriveKey();
    final iv = IV.fromUtf8(ivStr);

    final encrypter = Encrypter(AES(Key(key), mode: AESMode.cbc));
    final decrypted = encrypter.decrypt64(cipherTextBase64, iv: iv);

    return decrypted;
  }
}
