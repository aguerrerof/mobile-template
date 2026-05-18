import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/analitics_service.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:mobile_app_template/components/custom_scaffold.dart';
import 'package:mobile_app_template/components/custom_text_field.dart';
import 'package:mobile_app_template/utils/sigin_helper.dart';
import 'package:mobile_app_template/views/loading/loading_viewmodel.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:flutter_svg/svg.dart';
import '../register/register_viewmodel.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsService().trackScreen('Register User part 1 Screen');
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
                  padding: EdgeInsets.only(top: 29, bottom: 24),
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
                  "¿Cómo te llamas?",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: MyColors.navBarBackground,
                  ),
                ),

                const SizedBox(height: 24),
                CustomTextField(
                  placeholder: "Jhon",
                  title: "Nombre",
                  keyboardType: TextInputType.name,
                  onChanged: viewModel.setName,
                  errorText: viewModel.errorName,
                  titleFocusColor: MyColors.titleFocusTextColor,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  title: "Apellido",
                  placeholder: "Doe",
                  keyboardType: TextInputType.name,
                  onChanged: viewModel.setFirstName,
                  errorText: viewModel.errorFirstname,
                  titleFocusColor: MyColors.titleFocusTextColor,
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
                const SizedBox(height: 30),
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
    final status = viewModel.verifyStepOne();
    if (status) {
      Navigator.pushNamed(context, '/register-step-two');
    }
  }
}

