import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app_template/config/config.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/utils/encript_helper.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:http/http.dart' as http;

class ServicesAPIPayment {
  static final ServicesAPIPayment _instance = ServicesAPIPayment._internal();
  factory ServicesAPIPayment() => _instance;
  ServicesAPIPayment._internal();

  Future<GenericResult> addCardPayment(Map<String, dynamic> data) async {
    const url = '${GeneralConfig.apiURL}api/cards';
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }
      final dataEncripted = await encryptHybrid(data);
      final idToken = await user.getIdToken();
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({"body": dataEncripted}),
      );
      print(dataEncripted);
      final json = jsonDecode(response.body);
      final result = GenericResult<PaymentCardModel>.fromJson(
        json,
        (data) => PaymentCardModel.fromJson(data),
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        if (result.data == null) {
          throw Exception(
            result.getError() ?? 'Ocurrió un problema al agregar la tarjeta ',
          );
        } else {
          return result;
        }
      } else {
        print('Error en la solicitud: $response');
        throw Exception(
          result.getError() ?? 'Ocurrió un problema al agregar la tarjeta ',
        );
      }
    } catch (e) {
      print('Error: $e');
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult> verifyCodeOtp(Map<String, dynamic> data) async {
    const url = '${GeneralConfig.apiURL}api/cards/otp';
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }
      final idToken = await user.getIdToken();
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(data),
      );

      final json = jsonDecode(response.body);
      final result = GenericResult<PaymentCardModel>.fromJson(
        json,
        (data) => PaymentCardModel.fromJson(data),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 202 ||
          response.statusCode == 201) {
        if (result.data == null) {
          throw Exception(result.getError());
        } else {
          return result;
        }
      } else {
        print('Error en la solicitud: $response');
        throw Exception(
          result.getError() ?? 'Ocurrió un problema al agregar la tarjeta ',
        );
      }
    } catch (e) {
      print('Error: $e');
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult> verifyStep3DS(Map<String, dynamic> data) async {
    const url = GeneralConfig.apiURL;
    try {
      final baseUrl = Uri.parse(url);
      final uri = baseUrl.replace(
        path: "payments/3ds/callback",
        queryParameters: data,
      );
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      final json = jsonDecode(response.body);
      final result = GenericResult<GenericModel>.fromJson(json, null);

      if (response.statusCode == 200 ||
          response.statusCode == 202 ||
          response.statusCode == 201) {
        return result;
      } else {
        print('Error en la solicitud: $response');
        throw Exception(
          result.getError() ?? 'Ocurrió un problema al agregar la tarjeta ',
        );
      }
    } catch (e) {
      print('Error: $e');
      return GenericResult(
        success: false,
        data: null,
        errors: [GenericError(code: '', message: getFriendlyErrorMessage(e))],
      );
    }
  }

  Future<GenericResult> deleteCard(String token) async {
    const urlBase = GeneralConfig.apiURL;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final idToken = await user.getIdToken();
      final url = '${urlBase}api/cards/$token';
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({}),
      );

      final json = jsonDecode(response.body);
      final result = GenericResult<PaymentCardModel>.fromJson(
        json,
        (data) => PaymentCardModel.fromJson(data),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 202 ||
          response.statusCode == 201) {
        if (result.data == null) {
          throw Exception(result.getError());
        } else {
          return result;
        }
      } else {
        print('Error en la solicitud: $response');
        throw Exception(
          result.getError() ?? 'Ocurrió un problema al eliminar la tarjeta ',
        );
      }
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

