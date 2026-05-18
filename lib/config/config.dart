import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class GeneralConfig {
  static const String apiURL = '';
  static const String healthyCollectionId =
      "gid://shopify/Collection/306925994123";
  static const singularKey = '';
  static const singularSecret = '';

  final _secure = FlutterSecureStorage();
  static const _keyDeviceId = 'device_uuid';

  Future<String> getDeviceUuid() async {
    var id = await _secure.read(key: _keyDeviceId);
    if (id == null) {
      id = const Uuid().v4();
      await _secure.write(key: _keyDeviceId, value: id);
    }
    return id;
  }
}

