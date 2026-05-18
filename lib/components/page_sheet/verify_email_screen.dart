import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:mobile_app_template/components/custom_scaffold.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/utils/sigin_helper.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _timer;
  bool _isVerified = false;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _startEmailCheckTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startEmailCheckTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => checkVerification(context),
    );
  }

  Future<void> checkVerification(BuildContext context) async {
    setState(() => _checking = true);
    final user_ = FirebaseAuth.instance.currentUser;
    if (user_ != null) {
      await user_.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        _timer?.cancel();
        setState(() {
          _isVerified = true;
        });
        final isEnableNotifications = await haveNotificationPermission();
        if (!context.mounted) return;
        isEnableNotifications
            ? Navigator.pushNamed(context, '/home')
            : Navigator.pushNamed(context, '/enableNotifications');
      } else {
        setState(() => _checking = false);
      }
    } else {
      print("No hay usuario autenticado");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      useSafeArea: true,
      blockBack: true,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Se ha enviado un correo de verificación a tu dirección. Por favor, verifica tu correo para continuar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 30),
            if (_checking)
              const CircularProgressIndicator(
                color: Colors.grey,
                strokeWidth: 1.5,
              )
            else
              CustomButton(
                label: "He verificado mi correo",
                onPressed: () => checkVerification(context),
                type: CustomButtonType.filled,
              ),
            const SizedBox(height: 10),
            CustomButton(
              label: "Reenviar correo",
              onPressed: () => sendEmailVerification(),
              type: CustomButtonType.outline,
            ),

            const SizedBox(height: 30),
            CustomButton(
              label: "Cancelar",
              onPressed: () {
                logout(context);
              },
              type: CustomButtonType.outline,
            ),
            if (_isVerified)
              const Text(
                'Correo verificado correctamente.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

