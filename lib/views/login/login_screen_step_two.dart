import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/analitics_service.dart';
import 'package:mobile_app_template/components/check_card.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:mobile_app_template/components/custom_flushbar.dart';
import 'package:mobile_app_template/components/custom_scaffold.dart';
import 'package:mobile_app_template/components/password_card.dart';
import 'package:mobile_app_template/utils/sigin_helper.dart';
import 'package:mobile_app_template/views/login/login_viewmodel.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class LoginScreenStepTwo extends StatefulWidget {
  final bool? linkApple;

  const LoginScreenStepTwo({super.key, this.linkApple});

  @override
  State<LoginScreenStepTwo> createState() => LoginScreenStepTwoState();
}

class LoginScreenStepTwoState extends State<LoginScreenStepTwo> {
  @override
  void initState() {
    super.initState();
    AnalyticsService().trackScreen('Login User part 2 Screen');
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);

    return CustomScaffold(
      backgroundColor: MyColors.backgroundColor,
      cupertinoNavigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      materialNavigationBar: AppBar(actions: [
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 29, bottom: 29),
                  child: SvgPicture.asset(
                    'assets/icons/nameApp.svg',
                    // semanticsLabel: ' ',
                    fit: BoxFit.cover,
                    width: 140,
                    height: 39,
                    colorFilter: ColorFilter.mode(
                      MyColors.btnColor,
                      BlendMode.srcIn,
                    ),
                    //   ),
                    // ],
                  ),
                ),
                const Text(
                  "Inicia sesión",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Poppins',
                  ),
                ),

                RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    text: 'Selecciona cómo quieres acceder a tu cuenta para: ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontFamily: 'Poppins',
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: viewModel.email,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: MyColors.btnColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                PasswordCardWidget(
                  title: "Usar mi contraseña",
                  setPassword: viewModel.setPassword,
                  togglePasswordVisibility: viewModel.togglePasswordVisibility,
                  obscurePassword: viewModel.obscurePassword,
                  checked: viewModel.loginType == LoginType.password,
                  tapGesture: () {
                    viewModel.setLoginType(LoginType.password);
                  },
                  isCreatePassword: false,
                  backgroundColor: MyColors.backgroundColor,
                  borderColor: MyColors.selectedBorderColor,
                  borderColorChecked: MyColors.btnColor,
                ),
                CheckCardWidget(
                  textString: "Recuperar contraseña",
                  subtitleString:
                      "Te enviaremos un mail a tu correo ${viewModel.email} para que puedas restaurar tu contraseña",
                  checked: viewModel.loginType == LoginType.recover,
                  tapGesture: () {
                    viewModel.setLoginType(LoginType.recover);
                  },
                  backgroundColor: MyColors.backgroundColor,
                  borderColorChecked: MyColors.btnColor,
                ),

                const SizedBox(height: 20),
                Center(
                  child:
                      viewModel.isLoading
                          ? const CircularProgressIndicator(
                            color: Colors.grey,
                            strokeWidth: 1.5,
                          )
                          : SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              label: "Continuar",
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                handleRegister(
                                  context,
                                  viewModel,
                                  widget.linkApple ?? false,
                                );
                              },
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> handleRegister(
    BuildContext context,
    LoginViewModel viewModel,
    bool linkApple,
  ) async {
    switch (viewModel.loginType) {
      case LoginType.code:
      case LoginType.password:
        final (success, error) = await viewModel.singinWithEmailPassword(
          linkApple,
        );
        if (!context.mounted) return;
        if (success) {
          AnalyticsService().identifyUser();
          verifyUserInitialFlow(context);
        } else {
          showCustomFlushbar(context, message: error);
        }
      case LoginType.recover:
        final (status, message) = await viewModel.sendPasswordResetEmail();
        if (!context.mounted) return;
        showCustomFlushbar(
          context,
          message:
              status ? 'Verifica la bandeja de tu correo electrónico' : message,
          backgroundColor:
              status ? MyColors.successAlertColor : MyColors.acentOne,
          textColor: status ? MyColors.successAlerttextColor : Colors.white,
        );
    }
  }
}

