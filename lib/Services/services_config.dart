import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app_template/config/config.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:http/http.dart' as http;

class ServicesConfig {
  static final ServicesConfig _instance = ServicesConfig._internal();
  factory ServicesConfig() => _instance;
  ServicesConfig._internal();

  Future<T?> getConfig<T>(String key) async {
    final url = '${GeneralConfig.apiURL}api/settings';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      final json = jsonDecode(response.body);
      final settings = GenericResult<List<SettingsModel>>.fromJson(
        json,
        (data) => parseSettingsList(data),
      );

      if (settings.data?.isNotEmpty ?? false) {
        final setting = findByKey(settings.data!, key);

        if (T == int) {
          return setting?.asInt as T;
        }
        if (T == double) {
          return setting?.asDouble as T;
        }
        if (T == bool) {
          return setting?.asBool as T;
        }

        return setting?.value as T;
      } else {
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<List<String>> getCitiesStream(String text) async {
    final url = '${GeneralConfig.apiURL}api/cities?q=$text';
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final idToken = await user.getIdToken();

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      final json = jsonDecode(response.body);
      return parseStringList(json['data']);
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<GenericResult<List<Frequency>>> getFrecuencies() async {
    final url = '${GeneralConfig.apiURL}api/recurrence-frequencies';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      final json = jsonDecode(response.body);
      return GenericResult<List<Frequency>>.fromJson(
        json,
        (data) => parseFrecuencyList(data),
      );
    } catch (e) {
      print('Error: $e');
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }
}

