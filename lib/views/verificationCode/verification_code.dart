import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/components/container_footpet.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:mobile_app_template/components/custom_scaffold.dart';
import 'package:mobile_app_template/components/custom_text_field.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:mobile_app_template/views/verificationCode/verification_code_viewmodel.dart';
import '../register/register_viewmodel.dart';
import 'package:provider/provider.dart';

enum FlowsCodeVerification { login, register, otp }

class VerificationCode extends StatefulWidget {
  final FlowsCodeVerification flow;
  final String? subtitle;
  final PaymentCardModel paymentCard;

  const VerificationCode({
    super.key,
    required this.flow,
    this.subtitle,
    required this.paymentCard,
  });

  @override
  State<VerificationCode> createState() => _VerificationCodeState();
}

class _VerificationCodeState extends State<VerificationCode> {
  late VerificationCodeViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = VerificationCodeViewModel();
    viewModel.updateFlow(widget.flow);
    viewModel.updatePaymentCardModel(widget.paymentCard);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<VerificationCodeViewModel>(
        builder: (context, viewModel, child) {
          return CustomScaffold(
            cupertinoNavigationBar: CupertinoNavigationBar(
              backgroundColor: Colors.transparent,
              leading: CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            materialNavigationBar: AppBar(actions: []),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [const ContainerFootPet(), const Spacer()]),
                      const SizedBox(height: 20),
                      const Text(
                        "Ingresa código de verificación",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          text:
                              widget.subtitle ??
                              'Hemos enviado un código de verificación',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontFamily: 'Poppins',
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      CustomTextField(
                        placeholder: "",
                        title: "Código",
                        keyboardType: TextInputType.number,
                        onChanged: viewModel.updateCode,
                        errorText: viewModel.errorMessage ?? '',
                        titleFocusColor: MyColors.titleFocusTextColor,
                      ),
                      const SizedBox(height: 10),

                      const SizedBox(height: 20),
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            label: "Continuar",
                            onPressed:
                                () => viewModel.sendCodeValidatior(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> handleRegister(
    BuildContext context,
    RegisterViewModel viewModel,
  ) async {
    // Aquí va tu lógica de verificación del código
    print("Presionaste continuar");
  }
}

