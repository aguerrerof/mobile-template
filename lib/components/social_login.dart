import 'package:flutter/material.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io' show Platform;

class SocialLoginButtons extends StatelessWidget {
  final Function() onPress;
  final Function() appleOnPress;
  final bool showAppleOption;
  const SocialLoginButtons({
    super.key,
    required this.onPress,
    required this.appleOnPress,
    this.showAppleOption = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: const [
            Expanded(child: Divider(thickness: 1, color: Colors.grey)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'O',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Poppins',
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(child: Divider(thickness: 1, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 30),

        CustomButton(
          label: "Continuar con Google",
          onPressed: onPress,
          icon: SvgPicture.asset(
            'assets/icons/google.svg',
            semanticsLabel: ' ',
            width: 24,
            height: 24,
          ),
          type: CustomButtonType.outline,
          textColor: Colors.grey.shade800,
        ),
        const SizedBox(height: 12),
        if (Platform.isIOS && showAppleOption)
          SizedBox(
            height: 45,
            child: SignInWithAppleButton(onPressed: appleOnPress),
          ),
      ],
    );
  }
}

