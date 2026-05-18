import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class PushDemo extends StatefulWidget {
  const PushDemo({super.key});

  @override
  State<PushDemo> createState() => _PushDemoState();
}

class _PushDemoState extends State<PushDemo> {
  @override
  void initState() {
    super.initState();
    _setupFCM();
  }

  void _setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Solicitar permisos (iOS 10+)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('Permisos de notificación: ${settings.authorizationStatus}');

    // Obtener token FCM
    String? token = await messaging.getToken();
    print('Token FCM: $token');

    // Mensajes cuando la app está en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensaje foreground: ${message.notification?.title}');
    });

    // Mensajes cuando la app se abre desde notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Mensaje abierto: ${message.notification?.title}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Esperando notificaciones...')),
    );
  }
}
