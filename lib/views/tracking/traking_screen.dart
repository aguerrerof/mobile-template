import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:mobile_app_template/components/custom_scaffold.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';

class EnableTrackingScreen extends StatelessWidget {
  const EnableTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      navBarColor: MyColors.backgroundColor,
      useSafeArea: false,
      child: Column(
        children: [
          const SizedBox(height: 30),
          Expanded(
            child: Image.asset(
              'assets/images/tracking.png',
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 32),
          const Text(
            "¿Deseas una experiencia a la medida?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "Usamos datos para mostrarte recomendaciones de comida y contenido más relevante para ti.",
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
                label: "Continuar",
                onPressed: () => {requestPermission(context)},
                borderRadius: 23,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
          //   child: SizedBox(
          //     width: double.infinity,
          //     height: 45,
          //     child: CustomButton(
          //       label: "Ahora no",
          //       onPressed: () => {Navigator.pushNamed(context, '/home')},
          //       type: CustomButtonType.text,
          //     ),
          //   ),
          // ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Future<void> requestPermission(BuildContext context) async {
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      await Future.delayed(const Duration(milliseconds: 200));
      final result =
          await AppTrackingTransparency.requestTrackingAuthorization();
      print("Tracking autorizado: $result");
      if (!context.mounted) return;
      Navigator.pushNamed(context, '/home');
      return;
    }
    if (!context.mounted) return;
    Navigator.pushNamed(context, '/home');
  }
}

