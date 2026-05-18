import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/analitics_service.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:mobile_app_template/components/custom_flushbar.dart';
import 'package:mobile_app_template/components/custom_scaffold.dart';
import 'package:mobile_app_template/components/custom_text_field.dart';
import 'package:mobile_app_template/components/social_login.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/utils/sigin_helper.dart';
import 'package:mobile_app_template/views/loading/loading_viewmodel.dart';
import 'package:mobile_app_template/views/register/register_viewmodel.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:flutter_svg/svg.dart';
import 'package:singular_flutter_sdk/singular.dart';
import '../login/login_viewmodel.dart';
import 'package:provider/provider.dart';

class LoginScreenStepOne extends StatefulWidget {
  const LoginScreenStepOne({super.key});

  @override
  State<LoginScreenStepOne> createState() => LoginScreenStepOneState();
}

class LoginScreenStepOneState extends State<LoginScreenStepOne> {
  @override
  void initState() {
    super.initState();
    AnalyticsService().trackScreen('Login User part 1 Screen');
    Singular.event('Login User part 1 Screen');
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);
    final viewModelRegister = Provider.of<RegisterViewModel>(context);
    final loading = Provider.of<LoadingViewModel>(context);

    return CustomScaffold(
      backgroundColor: MyColors.backgroundColor,
      navBarColor: Colors.transparent,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 29, bottom: 24),
                child:
                // SizedBox(
                //   width: 140,
                //   child:
                SvgPicture.asset(
                  'assets/icons/nameApp.svg',
                  // semanticsLabel: ' ',
                  fit: BoxFit.cover,
                  width: 109,
                  height: 29,
                  colorFilter: ColorFilter.mode(
                    MyColors.btnColor,
                    BlendMode.srcIn,
                  ),
                  //   ),
                  // ],
                ),
                // Image.asset(
                //   'assets/images/app_name.png',
                //   fit: BoxFit.cover,
                //   colorBlendMode: BlendMode.srcIn,
                //   color: MyColors.btnColor,
                // ),
                // ),
              ),
              Text(
                "Inicia Sesión o crea una cuenta",
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                  color: MyColors.btnColor,
                ),
              ),

              SizedBox(height: 24),
              CustomTextField(
                title: "Correo electrónico",
                placeholder: "nombre@correo.com",
                keyboardType: TextInputType.emailAddress,
                onChanged: viewModel.setEmail,
                errorText: viewModel.errorEmail,
                titleFocusColor: MyColors.titleFocusTextColor,
              ),
              const SizedBox(height: 32),

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
                              handleLogin(
                                context,
                                viewModel,
                                viewModelRegister,
                              );
                            },
                            borderRadius: 24,
                          ),
                        ),
              ),
              const SizedBox(height: 30),
              SocialLoginButtons(
                onPress: () {
                  FocusScope.of(context).unfocus();
                  handleSocialLogin(context, viewModel, loading, true);
                },
                appleOnPress: () {
                  FocusScope.of(context).unfocus();
                  handleSocialLogin(context, viewModel, loading, false);
                },
              ),
              const SizedBox(height: 20),
              RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  text: 'Al continuar, aceptas nuestra ',
                  style: TextStyle(
                    color: getTextColor(context),
                    fontFamily: 'Poppins',
                    fontSize: 12,
                  ),
                  children: [
                    TextSpan(
                      text: 'Políticas de Privacidad',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.blueAccent,
                        fontSize: 12,
                      ),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () {
                              print('Políticas de Privacidad tocadas');
                            },
                    ),
                    TextSpan(
                      text: ' y nuestros ',
                      style: TextStyle(
                        color: getTextColor(context),
                        fontFamily: 'Poppins',
                        fontSize: 12,
                      ),
                    ),
                    TextSpan(
                      text: 'Términos y condiciones',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.blueAccent,
                        fontSize: 12,
                      ),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () {
                              print('Términos de uso tocados');
                            },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> handleLogin(
    BuildContext context,
    LoginViewModel viewModel,
    RegisterViewModel viewModelRegister,
  ) async {
    AnalyticsService().trackEvent("User starts login");
    if (viewModel.validateStepOne()) {
      final exist = await viewModel.existEmail();
      if (!context.mounted) return;
      if (exist) {
        Navigator.pushNamed(context, '/login-step-two');
      } else {
        viewModelRegister.setEmail(viewModel.email);
        Navigator.pushNamed(context, '/register');
      }
    }
  }

  Future<void> handleSocialLogin(
    BuildContext context,
    LoginViewModel viewModel,
    LoadingViewModel loading,
    bool google,
  ) async {
    print('inicia social login google');
    AnalyticsService().trackEvent("User starts social login");
    loading.show();
    if (google) {
      final (exist, message, canReactivate) = await signInWithGoogle(false);
      loading.hide();
      if (!context.mounted) return;
      if (exist) {
        AnalyticsService().identifyUser();
        verifyUserInitialFlow(context);
      } else if (canReactivate) {
        reactivateAlert(context, message);
      } else if (message != '') {
        showCustomFlushbar(context, message: message);
      }
    } else {
      final (exist, message, canReactivate) = await signInWithApple(
        context,
        loading,
      );
      loading.hide();
      if (!context.mounted) return;
      if (exist) {
        AnalyticsService().identifyUser();
        verifyUserInitialFlow(context);
      } else if (canReactivate) {
        reactivateAlert(context, message);
      } else if (message != '') {
        showCustomFlushbar(context, message: message);
      }
    }
  }
}

Future<String?> promptForEmail(BuildContext context) async {
  final emailController = TextEditingController();
  String? userEmail;

  await showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text("Correo requerido"),
        content: Column(
          children: [
            SizedBox(height: 10),
            Text(
              "No pudimos obtener tu correo electrónico desde Apple. Por favor ingrésalo para continuar.",
            ),
            SizedBox(height: 10),
            CupertinoTextField(
              controller: emailController,
              placeholder: "correo@ejemplo.com",
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(
              "Cancelar",
              style: TextStyle(
                color:
                    CupertinoTheme.of(context).brightness == Brightness.dark
                        ? CupertinoColors.white
                        : CupertinoTheme.of(context).primaryColor,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text("Aceptar"),
            onPressed: () {
              final input = emailController.text.trim();
              if (input.isNotEmpty && isValidEmail(input)) {
                userEmail = input;
                Navigator.of(context).pop();
              } else {
                showCustomFlushbar(
                  context,
                  message:
                      'Necesitamos un correo electrónico válido para poder continuar. ¡Gracias!',
                );
              }
            },
          ),
        ],
      );
    },
  );

  return userEmail;
}

