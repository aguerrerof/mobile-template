import 'package:flutter/material.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:mobile_app_template/components/custom_scaffold.dart';
import 'package:mobile_app_template/components/custom_text_field.dart';
import 'package:mobile_app_template/components/nav_bar_header.dart';
import 'package:mobile_app_template/components/password_card.dart';
import 'package:mobile_app_template/views/home/menu/changePassword/change_password_viewmodel.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late ChangePasswordViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = ChangePasswordViewModel();
    viewModel.getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<ChangePasswordViewModel>(
        builder: (context, vm, _) {
          return CustomScaffold(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (vm.oldPasswordIsNeeded)
                                Column(
                                  spacing: 10,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Contraseña actual",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    CustomTextField(
                                      placeholder: "",
                                      obscureText: true,
                                      onChanged: viewModel.setOldPassword,
                                    ),
                                  ],
                                ),
                              SizedBox(height: 20),
                              PasswordCardWidget(
                                title: "Nueva contraseña",
                                setPassword: viewModel.setPassword,
                                setConfPassword: viewModel.setConfPassword,
                                togglePasswordVisibility:
                                    viewModel.togglePasswordVisibility,
                                toggleConfPasswordVisibility:
                                    viewModel.toggleConfPasswordVisibility,
                                obscurePassword: viewModel.obscurePassword,
                                obscureConfPassword:
                                    viewModel.obscureConfPassword,
                                checked: true,
                                tapGesture: () {},
                                isCreatePassword: true,
                                backgroundColor: MyColors.backgroundColor,
                                borderColor: Colors.transparent,
                                showCheck: false,
                                showBorder: false,
                                padding: EdgeInsets.all(0),
                                password: viewModel.password,
                                confirmPassword: viewModel.confirmPassword,
                              ),
                              const SizedBox(height: 24),
                              CustomButton(
                                label:
                                    vm.oldPasswordIsNeeded
                                        ? "Actualizar"
                                        : "Crea Contraseña",
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  viewModel.updatePasswordUser(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Header fijo encima
                NavBarHeader(
                  searchBelow: false,
                  showImageApp: false,
                  showSearch: false,
                  showShoppingCart: false,
                  showBackButton: true,
                  children: Center(
                    child: Text(
                      "Contraseña",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        color: MyColors.navBarText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

