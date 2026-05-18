import 'package:flutter/material.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';

void showCardLinkedPopup(
  BuildContext context, {
  required VoidCallback onPressed,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: MyColors.backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withAlpha(100),
                ),
                padding: const EdgeInsets.all(15),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "¡Tarjeta vinculada!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: getTextColor(context),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              Text(
                "Tu tarjeta ha sido guardada exitosamente y ya puedes usarla para tus pagos.",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: getTextColor(context),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              CustomButton(onPressed: onPressed, label: "Aceptar"),
            ],
          ),
        ),
      );
    },
  );
}

