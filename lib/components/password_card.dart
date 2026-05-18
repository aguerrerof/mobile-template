import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/components/custom_text_field.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/register/password_requeriment.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';

class PasswordCardWidget extends StatelessWidget {
  final String title;
  final bool checked;
  final void Function(String) setPassword;
  final bool obscurePassword;
  final void Function() togglePasswordVisibility;
  final void Function(String)? setConfPassword;
  final bool obscureConfPassword;
  final void Function()? toggleConfPasswordVisibility;
  final void Function() tapGesture;
  final bool isCreatePassword;
  final bool showCheck;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool showBorder;
  final EdgeInsets? padding;
  final String password;
  final String confirmPassword;
  final Color? borderColorChecked;

  const PasswordCardWidget({
    super.key,
    this.title = "",
    this.checked = false,
    required this.setPassword,
    this.obscurePassword = false,
    required this.togglePasswordVisibility,
    this.setConfPassword,
    this.obscureConfPassword = false,
    this.toggleConfPasswordVisibility,
    required this.tapGesture,
    this.isCreatePassword = false,
    this.showCheck = true,
    this.backgroundColor,
    this.borderColor,
    this.showBorder = true,
    this.padding,
    this.password = '',
    this.confirmPassword = '',
    this.borderColorChecked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tapGesture,
      child: Card(
        shape:
            showBorder
                ? RoundedRectangleBorder(
                  side:
                      checked
                          ? BorderSide(
                            color:
                                borderColorChecked ??
                                MyColors.selectedBorderColor,
                            width: 2,
                          )
                          : BorderSide(
                            color: borderColor ?? MyColors.borderColor,
                            width: 1,
                          ),
                  borderRadius: BorderRadius.circular(12),
                )
                : null,
        elevation: showBorder ? 1 : 0,
        color: backgroundColor ?? MyColors.cardColor,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Título con icono
              if (title.isNotEmpty || showCheck)
                Row(
                  spacing: 8,
                  children: [
                    if (showCheck)
                      Icon(
                        checked
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked_outlined,
                        color:
                            checked
                                ? borderColorChecked ??
                                    MyColors.selectedBorderColor
                                : borderColor ?? MyColors.borderColor,
                      ),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: getTextColor(context),
                      ),
                    ),
                  ],
                ),
              if (checked)
                Column(
                  children: [
                    const SizedBox(height: 8),
                    CustomTextField(
                      placeholder: "",
                      title: "Ingresa tu contraseña",
                      titleFocusColor: MyColors.titleFocusTextColor,
                      // borderColor: Color(0xFF3B3BEA),
                      onChanged: setPassword,
                      obscureText: obscurePassword,
                      suffix: GestureDetector(
                        onTap: togglePasswordVisibility,
                        child: Icon(
                          obscurePassword
                              ? CupertinoIcons.eye_slash
                              : CupertinoIcons.eye,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    if (isCreatePassword)
                      CustomTextField(
                        title: "Confirma tu contraseña",
                        placeholder: "",
                        titleFocusColor: MyColors.titleFocusTextColor,
                        onChanged: setConfPassword,
                        obscureText: obscureConfPassword,
                        suffix: GestureDetector(
                          onTap: toggleConfPasswordVisibility,
                          child: Icon(
                            obscureConfPassword
                                ? CupertinoIcons.eye_slash
                                : CupertinoIcons.eye,
                          ),
                        ),
                      ),

                    if (isCreatePassword)
                      PasswordRequirements(
                        hasMinLength: password.length >= 8,
                        passwordsMatch:
                            password == confirmPassword && password != '',
                      ),
                    const SizedBox(height: 4),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

