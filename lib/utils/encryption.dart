import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';

const String passkey = 'b14ca5898a4e4133bbce2ea231573137'; // 32-char AES key

String decryptPassword(String base64Encrypted) {
  final key = Uint8List.fromList(utf8.encode(passkey));
  final iv = Uint8List(16);

  final cb = base64Decode(base64Encrypted);

  final cipher = CBCBlockCipher(AESFastEngine())
    ..init(false, ParametersWithIV(KeyParameter(key), iv));
  final paddedop = Uint8List(cb.length);
  for (int offset = 0; offset < cb.length;) {
    offset += cipher.processBlock(cb, offset, paddedop, offset);
  }
  final padCount = paddedop.last;
  final unpadded = paddedop.sublist(0, paddedop.length - padCount);

  return utf8.decode(unpadded);
}

bool validatePassword(String inputPassword, String storedHash) {
  final decrypted = decryptPassword(storedHash);
  return decrypted == inputPassword;
}
