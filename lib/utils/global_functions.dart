import 'dart:ffi';
import 'dart:io';
import 'dart:math';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/services_api.dart';
import 'package:mobile_app_template/config/config.dart';
import 'package:mobile_app_template/main.dart' show navigatorKey;
import 'package:mobile_app_template/models/pet_health_models.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/utils/local_persistence.dart';
import 'package:mobile_app_template/utils/notification_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

bool isValidEmail(String email) {
  final RegExp emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
  return emailRegex.hasMatch(email);
}

Future<bool> haveNotificationPermission() async {
  try {
    NotificationSettings settings =
        await FirebaseMessaging.instance.getNotificationSettings();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Notificaciones permitidas');
      return true;
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.notDetermined) {
      print('❔ Permiso aún no solicitado');
      return false;
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return false;
    }
    return false;
  } catch (e) {
    print('Error verificando permisos: $e');
    return false;
  }
}

Future<void> setupFirebaseMessaging() async {
  try {
    await Firebase.initializeApp();

    await FirebaseAppCheck.instance.activate(
      providerAndroid: AndroidPlayIntegrityProvider(),
      providerApple: AppleDeviceCheckProvider(),
    );

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    final isEnableNotifications = await haveNotificationPermission();
    if (!isEnableNotifications) return;

    final messaging = FirebaseMessaging.instance;

    final token = await messaging.getToken();
    if (token != null) {
      await ServicesAPI().setToken(token);
    }

    //  Refresh de token
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      ServicesAPI().setToken(newToken);
    });

    // Manejar notificaciones cuando la app está en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
        'Notificación recibida en foreground: ${message.notification?.title}',
      );
      _handleNotification(message);
    });

    // Manejar notificaciones cuando la app se abre desde una notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App abierta desde notificación: ${message.notification?.title}');
      _handleNotification(message);
    });

    // Manejar notificación cuando la app se abre desde un estado terminado
    // Diferir hasta después del primer frame para que el Navigator esté disponible
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      print(
        'App abierta desde notificación (estado terminado): ${initialMessage.notification?.title}',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNotification(initialMessage);
      });
    }
  } catch (e, stack) {
    print(" Error al inicializar Firebase Messaging: $e");
    print(stack);
  }
}

void _handleNotification(RemoteMessage message) {
  final data = message.data;
  final route = data['route'] as String?;
  final id = data['id'] as String?;

  if (route != null) {
    // Verificar si debemos procesar inmediatamente o almacenar
    if (_shouldProcessImmediately()) {
      print('Procesando notificación inmediatamente: $route, $id');
      navigateToRouteWithRetry(route, id);
    } else {
      // Almacenar la notificación pendiente para procesarla en HomeScreen
      NotificationManager().setPendingNotification(route, id);
      print('Notificación pendiente almacenada: $route, $id');
    }
  } else {
    print('Notificación sin ruta especificada');
  }
}

bool _shouldProcessImmediately() {
  // Si el usuario está logueado, procesar inmediatamente
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null && currentUser.emailVerified) {
    return true;
  }

  // Si no está logueado, verificar si está en una pantalla permitida
  final context = navigatorKey.currentContext;
  if (context != null) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    final allowedRoutes = {
      '/welcome',
      '/login-one',
      '/login-step-two',
      '/register',
      '/register-step-two',
      '/enableNotifications',
      '/verifyEmail',
      '/trackingScreen',
    };

    return !allowedRoutes.contains(currentRoute);
  }

  // Por defecto, no procesar inmediatamente
  return false;
}

Future<void> navigateToRouteWithRetry(
  String route,
  String? id, {
  int retries = 15,
}) async {
  // Esperar a que el Navigator esté disponible
  for (int i = 0; i < retries; i++) {
    if (navigatorKey.currentContext != null) {
      await _navigateToRoute(route, id);
      return;
    }
    await Future.delayed(const Duration(milliseconds: 200));
  }
  print(
    'No se pudo navegar: Navigator no disponible después de $retries intentos',
  );
}

Future<void> _navigateToRoute(String route, String? id) async {
  try {
    final context = navigatorKey.currentContext;
    if (context == null) {
      print('Error: Navigator context no disponible');
      return;
    }

    // Asegurar que la ruta comience con /
    final routePath = route.startsWith('/') ? route : '/$route';

    switch (routePath) {
      case '/orderDetail':
        Map<String, dynamic>? arguments = await _getRouteArguments(
          routePath,
          id,
        );
        if (arguments != null && context.mounted) {
          Navigator.pushNamed(context, routePath, arguments: arguments);
        } else {
          print(
            'No se pudieron obtener los argumentos para la ruta $routePath con ID $id',
          );
        }

      // case '/recurringOrderDetail':

      // case '/productDetail':

      default:
        break;
    }
  } catch (e) {
    print('Error al navegar a la ruta $route: $e');
  }
}

Future<Map<String, dynamic>?> _getRouteArguments(
  String routePath,
  String? id,
) async {
  // Rutas que requieren obtener datos por ID
  if (id != null) {
    switch (routePath) {
      case '/orderDetail':
        final result = await ServicesAPI().getOrderById(id);
        if (result.success && result.data != null) {
          return {'order': result.data};
        } else {
          print('Error al obtener la orden: ${result.getError()}');
          return null;
        }

      case '/recurringOrderDetail':
        // TODO: Implementar getRecurringOrderById si es necesario
        // Por ahora, retornar null para indicar que no está implementado
        print(
          'Navegación a recurringOrderDetail con ID: $id (no implementado)',
        );
        return null;

      case '/productDetail':
        // TODO: Implementar getProductById si es necesario
        print('Navegación a productDetail con ID: $id (no implementado)');
        return null;

      default:
        // Para rutas desconocidas que requieren ID, pasar el ID como argumento
        return {'id': id};
    }
  }

  // // Rutas que no requieren argumentos o ID
  // switch (routePath) {
  //   case '/home':
  //   case '/shopingCart':
  //   case '/checkout':
  //   case '/orderList':
  //   case '/petHealth':
  //   case '/searchScreen':
  //   case '/welcome':
  //   case '/login-one':
  //     return null; // No requieren argumentos

  //   default:
  //     // Para otras rutas sin ID, retornar null (sin argumentos)
  return null;
  // }
}

Future<void> syncTokenIfLoggedIn() async {
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    await ServicesAPI().setToken(token);
  }
}

String getFriendlyErrorMessage(dynamic error) {
  if (error is FirebaseAuthException) {
    return error.message ?? 'Ocurrió un error inesperado.';
  } else if (error is Exception) {
    final text = error.toString();
    if (text.startsWith('Exception: ')) {
      return text.replaceFirst('Exception: ', '');
    } else if (text.startsWith('Error: ')) {
      return text.replaceFirst('Error: ', '');
    } else {
      return text;
    }
  } else {
    return 'Ha ocurrido un error desconocido.';
  }
}

String generateRandomPassword({int length = 16, bool includeSymbols = true}) {
  const String letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const String numbers = '0123456789';
  const String symbols = '!@#\$%^&*()-_=+[]{}<>?';

  final String chars = letters + numbers + (includeSymbols ? symbols : '');
  final Random random = Random.secure();

  return List.generate(
    length,
    (index) => chars[random.nextInt(chars.length)],
  ).join();
}

Future<void> sendEmailVerification() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return;
  }
  user.reload();
  if (!user.emailVerified) {
    await FirebaseAuth.instance.currentUser?.sendEmailVerification();
  }
}

List<Product> parseProductList(dynamic json) {
  final edges = json['edges'] as List<dynamic>;
  return edges
      .map((edge) => Product.fromJson(edge['node'] as Map<String, dynamic>))
      .toList();
}

List<GenericModel> parseGenericList(dynamic json) {
  final edges = json['edges'] as List<dynamic>;
  return edges
      .map(
        (edge) => GenericModel.fromJson(edge['node'] as Map<String, dynamic>),
      )
      .toList();
}

List<Product> parseSimpleProductList(dynamic json) {
  final products = json as List<dynamic>;
  return products
      .map((product) => Product.fromJson(product as Map<String, dynamic>))
      .toList();
}

List<CartItem> parseCartList(dynamic json) {
  final cart = json as List<dynamic>;
  return cart
      .map((product) => CartItem.fromJson(product as Map<String, dynamic>))
      .toList();
}

List<CardDetail> parseCardList(dynamic json) {
  final card = json as List<dynamic>;
  return card
      .map((item) => CardDetail.fromJson(item as Map<String, dynamic>))
      .toList();
}

List<CustomerBilling> parseCustomerBillingList(dynamic json) {
  final cart = json as List<dynamic>;
  return cart
      .map(
        (customer) =>
            CustomerBilling.fromJson(customer as Map<String, dynamic>),
      )
      .toList();
}

List<Address> parseAddressList(dynamic json) {
  final edges = json as List<dynamic>;
  return edges
      .map((item) => Address.fromJson(item as Map<String, dynamic>))
      .toList();
}

List<Order> parseOrderList(dynamic json) {
  final List<dynamic> edges;
  if (json is List<dynamic>) {
    edges = json;
  } else if (json is Map<String, dynamic>) {
    final nested = json['orders'] ?? json['items'] ?? json['data'];
    if (nested is List<dynamic>) {
      edges = nested;
    } else {
      throw const FormatException(
        'parseOrderList: data is a Map but no orders/items/data list found',
      );
    }
  } else {
    throw FormatException(
      'parseOrderList: unexpected type ${json.runtimeType}',
    );
  }
  return edges
      .map((item) => Order.fromJson(item as Map<String, dynamic>))
      .toList();
}

List<RecurringOrder> parseRecurringOrderList(dynamic json) {
  final edges = json as List<dynamic>;
  return edges
      .map((item) => RecurringOrder.fromJson(item as Map<String, dynamic>))
      .toList();
}

List<Frequency> parseFrecuencyList(dynamic json) {
  final generic = json as List<dynamic>;
  return generic
      .map((item) => Frequency.fromJson(item as Map<String, dynamic>))
      .toList();
}

List<Species> parseSpeciesList(dynamic json) {
  final edges = json as List<dynamic>;
  return edges
      .map((item) => Species.fromJson(item as Map<String, dynamic>))
      .toList();
}

List<Breed> parseBreedList(dynamic json) {
  final edges = json as List<dynamic>;
  return edges
      .map((item) => Breed.fromJson(item as Map<String, dynamic>))
      .toList();
}

List<Symptom> parseSymptomList(dynamic json) {
  final edges = json as List<dynamic>;
  return edges
      .map((item) => Symptom.fromJson(item as Map<String, dynamic>))
      .toList();
}

List<MedicalCondition> parseMedicalConditionList(dynamic json) {
  final edges = json as List<dynamic>;
  return edges
      .map((item) => MedicalCondition.fromJson(item as Map<String, dynamic>))
      .toList();
}

List<SettingsModel> parseSettingsList(dynamic json) {
  final generic = json as List<dynamic>;
  return generic
      .map((item) => SettingsModel.fromJson(item as Map<String, dynamic>))
      .toList();
}

List<String> parseStringList(dynamic json) {
  final generic = json as List<dynamic>;
  return generic.map((e) => e['name'].toString()).toList();
}

SettingsModel? findByKey(List<SettingsModel> list, String key) {
  try {
    return list.firstWhere((item) => item.key == key);
  } catch (e) {
    return null;
  }
}

void safePopUntil(BuildContext context, String routeName) {
  bool found = false;

  Navigator.popUntil(context, (route) {
    if (route.settings.name == routeName) {
      found = true;
      return true;
    }
    return false;
  });

  if (!found) {
    safePop(context);
  }
}

void safePop(BuildContext context) {
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  } else {
    debugPrint('⚠️ No hay rutas para hacer pop en este Navigator');
  }
}

Color? getTextColor(BuildContext context) {
  if (Platform.isIOS) {
    return CupertinoTheme.of(context).textTheme.textStyle.color;
  } else {
    return Theme.of(context).textTheme.bodyMedium?.color;
  }
}

Color? hexToColor(String hex) {
  if (hex == '') {
    return null;
  }
  hex = hex.replaceAll("#", "");
  if (hex.length == 6) {
    hex = "FF$hex";
  }
  return Color(int.parse(hex, radix: 16));
}

String addProductVariantIdToNumber(String id) {
  if (id.contains("gid://shopify/")) {
    return id;
  } else {
    return 'gid://shopify/ProductVariant/$id';
  }
}

Future<void> openUrl(String url) async {
  final uri = Uri.parse(url);

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}

