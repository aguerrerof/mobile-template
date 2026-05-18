import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/services_api.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:mobile_app_template/components/custom_scaffold.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:permission_handler/permission_handler.dart';

class EnableNotificationsScreen extends StatelessWidget {
  const EnableNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      navBarColor: MyColors.backgroundColor,
      useSafeArea: false,
      child: Column(
        children: [
          Expanded(
            child: Image.asset(
              'assets/images/notifications.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Activa las notificaciones y mantente informado.",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "Recibe las notificaciones de entrega, suscripciones y siguientes fechas de cobro.",
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "Puedes modificarlo en cualquier momento.",
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              width: double.infinity,
              height: 45,
              child: CustomButton(
                label: "Activar notificaciones",
                onPressed: () => {requestNotificationPermission(context)},
                borderRadius: 23,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              width: double.infinity,
              height: 45,
              child: CustomButton(
                label: "Ahora no",
                onPressed: () => {nextStep(context)},
                type: CustomButtonType.text,
              ),
            ),
          ),

          const SizedBox(height: 60),
        ],
      ),
      // ),
    );
  }

  Future<void> requestNotificationPermission(BuildContext context) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permiso de notificaciones concedido');
      final token = await FirebaseMessaging.instance.getToken();
      print('token de firebase: $token');
      if (token != null) {
        await ServicesAPI().setToken(token);
      }
      if (!context.mounted) return;
      nextStep(context);
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('Permiso provisional de notificaciones');
      final token = await FirebaseMessaging.instance.getToken();
      print('token de firebase: $token');
      if (token != null) {
        await ServicesAPI().setToken(token);
      }
      if (!context.mounted) return;
      nextStep(context);
    } else {
      print('Permiso de notificaciones denegado');
      if (!context.mounted) return;
      nextStep(context);
      openAppSettings();
    }
  }

  void nextStep(BuildContext context) async {
    if (Platform.isIOS) {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        if (!context.mounted) return;
        Navigator.pushNamed(context, '/trackingScreen');
        return;
      }
    }
    if (!context.mounted) return;
    Navigator.pushNamed(context, '/home');
  }
}

