import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/analitics_service.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:mobile_app_template/components/custom_flushbar.dart';
import 'package:mobile_app_template/components/custom_scaffold.dart';
import 'package:mobile_app_template/components/password_card.dart';
import 'package:mobile_app_template/utils/sigin_helper.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:flutter_svg/svg.dart';
import '../register/register_viewmodel.dart';
import 'package:provider/provider.dart';

class RegisterScreenStepTwo extends StatefulWidget {
  const RegisterScreenStepTwo({super.key});

  @override
  State<RegisterScreenStepTwo> createState() => RegisterScreenStepTwoState();
}

class RegisterScreenStepTwoState extends State<RegisterScreenStepTwo> {
  @override
  void initState() {
    super.initState();
    AnalyticsService().trackScreen('Register User part 2 Screen');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<RegisterViewModel>(context, listen: false);
      viewModel.refreshPasswords();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RegisterViewModel>(context);

    return CustomScaffold(
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
                Text(
                  "Crea tu contraseña",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: MyColors.navBarBackground,
                  ),
                ),

                SizedBox(height: 24),
                PasswordCardWidget(
                  setPassword: viewModel.setPassword,
                  setConfPassword: viewModel.setConfPassword,
                  togglePasswordVisibility: viewModel.togglePasswordVisibility,
                  toggleConfPasswordVisibility:
                      viewModel.toggleConfPasswordVisibility,
                  obscurePassword: viewModel.obscurePassword,
                  obscureConfPassword: viewModel.obscureConfPassword,
                  showCheck: false,
                  checked: true,
                  tapGesture: () {
                    viewModel.selectRegisterType(RegisterType.password);
                  },
                  isCreatePassword: true,
                  password: viewModel.password,
                  confirmPassword: viewModel.confirmPassword,
                  backgroundColor: MyColors.backgroundColor,

                  showBorder: false,
                  padding: EdgeInsets.all(0),
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
                                handleRegister(context, viewModel);
                              },
                              borderRadius: 23,
                            ),
                          ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> handleRegister(
    BuildContext context,
    RegisterViewModel viewModel,
  ) async {
    final (success, error, canReactivate) = await viewModel.registerUser(
      context,
    );
    if (success) {
      AnalyticsService().identifyUser();
      verifyUserInitialFlow(context);
    } else if (canReactivate) {
      reactivateAlert(context, error);
    } else if (error.isNotEmpty) {
      showCustomFlushbar(context, message: error);
    }
  }
}

