import 'package:flutter/material.dart';
import 'package:mobile_app_template/utils/global_functions.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  String? _pendingRoute;
  String? _pendingId;
  bool _isProcessing = false;

  void setPendingNotification(String route, String? id) {
    _pendingRoute = route;
    _pendingId = id;
    print('Notificación pendiente guardada: $_pendingRoute, $_pendingId');
  }

  bool hasPendingNotification() {
    return _pendingRoute != null;
  }

  Future<void> processPendingNotification(BuildContext context) async {
    if (_isProcessing || _pendingRoute == null) return;

    _isProcessing = true;

    try {
      final route = _pendingRoute!;
      final id = _pendingId;

      // Limpiar la notificación pendiente
      _pendingRoute = null;
      _pendingId = null;

      // Esperar un momento para asegurar que el contexto esté listo
      await Future.delayed(const Duration(milliseconds: 300));

      if (context.mounted) {
        print('Procesando notificación pendiente: $route, $id');
        await _navigateToRouteWithRetry(route, id);
      }
    } catch (e) {
      print('Error procesando notificación pendiente: $e');
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _navigateToRouteWithRetry(String route, String? id) async {
    // Usar la misma lógica que en global_functions.dart
    await navigateToRouteWithRetry(route, id);
  }
}

