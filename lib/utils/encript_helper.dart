import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<String> loadPublicKey() async {
  return await rootBundle.loadString('assets/public.pem');
}

/// Parsea la clave pública
RSAPublicKey parsePublicKeyFromPem(String pem) {
  final parser = RSAKeyParser();
  return parser.parse(pem) as RSAPublicKey;
}

/// Genera un IV de 16 bytes para AES
IV generateRandomIV() {
  final rand = Random.secure();
  return IV.fromLength(16)
    ..bytes.setAll(0, List.generate(16, (_) => rand.nextInt(256)));
}

/// Genera una clave AES aleatoria de 32 bytes (AES-256)
Key generateRandomAESKey() {
  final rand = Random.secure();
  final keyBytes = List<int>.generate(32, (_) => rand.nextInt(256));
  return Key(Uint8List.fromList(keyBytes));
}

/// Encripta los datos con AES y la clave con RSA
Future<Map<String, String>> encryptHybrid(Map<String, dynamic> data) async {
  //obtener clave publcia
  final publicKeyPem = await loadPublicKey();

  // 1. Generar clave AES e IV
  final aesKey = generateRandomAESKey();
  final iv = generateRandomIV();

  // 2. Encriptar los datos con AES
  final aesEncrypter = Encrypter(AES(aesKey, mode: AESMode.cbc));
  final jsonData = jsonEncode(data);
  final encryptedData = aesEncrypter.encrypt(jsonData, iv: iv);

  // 3. Encriptar la clave AES con RSA
  final publicKey = parsePublicKeyFromPem(publicKeyPem);
  final rsaEncrypter = Encrypter(
    RSA(publicKey: publicKey, encoding: RSAEncoding.OAEP),
  );
  final encryptedKey = rsaEncrypter.encryptBytes(aesKey.bytes);

  // 4. Retornar base64s
  return {
    'encryptedData': encryptedData.base64,
    'encryptedKey': encryptedKey.base64,
    'iv': iv.base64,
  };
}
