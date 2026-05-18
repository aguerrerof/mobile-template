import 'package:flutter/cupertino.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:mobile_app_template/components/custom_flushbar.dart';
import 'package:mobile_app_template/components/social_login.dart';
import 'package:mobile_app_template/utils/sigin_helper.dart';
import 'package:mobile_app_template/views/loading/loading_viewmodel.dart';
import 'package:mobile_app_template/views/login/login_viewmodel.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:provider/provider.dart';

void showCustomCupertinoActionSheet(
  BuildContext context,
  String email,
  bool showGoogle,
  bool showEmailPass,
  LoadingViewModel loading,
) {
  Future<void> handleSocialLogin(
    BuildContext context,
    LoadingViewModel loading,
  ) async {
    loading.show();
    final (exist, message, canReactivate) = await signInWithGoogle(true);
    loading.hide();
    if (!context.mounted) return;
    if (exist) {
      verifyUserInitialFlow(context);
    } else if (message != '') {
      showCustomFlushbar(context, message: message);
    }
  }

  Future<void> handleEmailPass(BuildContext context) async {
    final viewModel = Provider.of<LoginViewModel>(context, listen: false);
    viewModel.setEmail(email);

    Navigator.pushNamed(
      context,
      '/login-step-two',
      arguments: {'linkApple': true},
    );
  }

  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: MyColors.backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(22),
            topRight: Radius.circular(22),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey3,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(
                'Conflicto de cuenta',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 8),
              Text(
                'El correo ingresado ya está vinculado a otras cuentas. '
                'Para continuar, por favor inicia sesión con una de las siguientes opciones:',
                style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
              ),
              SizedBox(height: 20),
              if (showGoogle)
                SocialLoginButtons(
                  showAppleOption: false,
                  appleOnPress: () {},
                  onPress: () => handleSocialLogin(context, loading),
                ),
              SizedBox(height: 10),
              CustomButton(
                label: "Iniciar con correo/contraseña",
                onPressed: () => handleEmailPass(context),
                type: CustomButtonType.outline,
              ),
              SizedBox(height: 20),
              CustomButton(
                label: "Cancelar",
                onPressed: () {
                  Navigator.pop(context);
                },
                type: CustomButtonType.outline,
              ),
            ],
          ),
        ),
      );
    },
  );
}

