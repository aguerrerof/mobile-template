import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app_template/Services/analitics_service.dart';
import 'package:mobile_app_template/components/add_credit_card_widget.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:mobile_app_template/components/custom_scaffold.dart';
import 'package:mobile_app_template/components/custom_text_field.dart';
import 'package:mobile_app_template/components/nav_bar_header.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/utils/card_functions.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/home/payments/card_popup/card_linked_popup.dart';
import 'package:mobile_app_template/views/home/payments/new_card_view_model.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:provider/provider.dart';
import 'package:singular_flutter_sdk/singular.dart';

class CreateCardScreen extends StatefulWidget {
  final bool fromCheckout;
  const CreateCardScreen({Key? key, required this.fromCheckout});

  @override
  State<CreateCardScreen> createState() => CreateCardContentState();
}

class CreateCardContentState extends State<CreateCardScreen> {
  late CreateCardViewModel viewModel;
  final TextEditingController controllerCardNumber = TextEditingController();

  @override
  void initState() {
    super.initState();
    AnalyticsService().trackScreen('Register Card Screen');
    Singular.event("Register Card Screen");

    viewModel = CreateCardViewModel();
    viewModel.fetchAddresses();
    viewModel.fetchCustomersBilling();
  }

  @override
  void dispose() {
    controllerCardNumber.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<CreateCardViewModel>(
        builder: (context, vm, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.showpopup) {
              viewModel.updateShowpopup(false);
              showCardLinkedPopup(
                context,
                onPressed: () {
                  if (widget.fromCheckout) {
                    Navigator.popUntil(
                      context,
                      ModalRoute.withName('/checkout'),
                    );
                  } else {
                    Navigator.popUntil(
                      context,
                      ModalRoute.withName('/listCreditCard'),
                    );
                  }
                },
              );
            }
          });

          return CustomScaffold(
            // cupertinoNavigationBar: CupertinoNavigationBar(
            //   backgroundColor: Colors.transparent,
            //   leading: CupertinoButton(
            //     padding: EdgeInsets.zero,
            //     child: const Icon(CupertinoIcons.back),
            //     onPressed: () => Navigator.pop(context),
            //   ),
            // ),
            // materialNavigationBar: AppBar(actions: []),
            useSafeArea: true,
            child: Column(
              children: [
                NavBarHeader(
                  showBackButton: true,
                  showSearch: false,
                  showShoppingCart: false,
                  searchBelow: false,
                  showImageApp: false,
                  children: Center(
                    child: Text(
                      'Vincular tarjeta',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: MyColors.navBarText,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Configura tu tarjeta',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 20),
                            child: Divider(
                              color: Colors.grey.shade200,
                              height: 2,
                            ),
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                'Registra tu tarjeta de crédito o débito',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 20),
                              Row(
                                spacing: 5,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      // maxHeight: 40,
                                      controller: controllerCardNumber,
                                      title: "Número de la tarjeta",
                                      placeholder: "xxxx xxxx xxxx xxxx",
                                      keyboardType: TextInputType.number,
                                      maxLength: 19,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        _CardNumberInputFormatter(),
                                      ],
                                      onChanged: viewModel.updateCardNumber,
                                    ),
                                  ),
                                  // SizedBox(
                                  //   width: 45,
                                  //   child: GestureDetector(
                                  //     onTap: () {
                                  //       vm.scanCard(
                                  //         context,
                                  //         controllerCardNumber,
                                  //       );
                                  //     },
                                  //     child: Padding(
                                  //       padding: EdgeInsetsGeometry.only(
                                  //         top: 10,
                                  //       ),
                                  //       child: Icon(
                                  //         Icons.camera_alt,
                                  //         size: 25,
                                  //         color: MyColors.btnColor,
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),

                              SizedBox(height: 10),
                              CustomTextField(
                                title: "Nombre del titular",
                                placeholder: "Nombre tarjeta",
                                keyboardType: TextInputType.name,
                                maxLength: 50,
                                onChanged: viewModel.updateCardName,
                                inputFormatters: [UpperCaseTextFormatter()],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      title: "Fecha de expiración",
                                      placeholder: "MM/YY",
                                      keyboardType: TextInputType.number,
                                      maxLength: 5,
                                      inputFormatters: [
                                        _CardDateInputFormatter(),
                                      ],
                                      onChanged: viewModel.updateCardDate,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: CustomTextField(
                                      title: "Código CVV",
                                      placeholder: "CVV",
                                      keyboardType: TextInputType.number,
                                      maxLength: 4,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(4),
                                      ],
                                      obscureText: true,
                                      onChanged: viewModel.updateCardCVV,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Dirección del titular',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Divider(
                                  color: Colors.grey.shade200,
                                  height: 2,
                                ),
                              ),
                              viewModel.addressLoading
                                  ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.grey,
                                      strokeWidth: 1.5,
                                    ),
                                  )
                                  : SizedBox(
                                    height: 60,
                                    child:
                                        viewModel.addressSelected == null
                                            ? Padding(
                                              padding: EdgeInsets.only(top: 10),
                                              child: AddDottedCardButton(
                                                title: 'Seleccionar dirección',
                                                icon: Icon(
                                                  Icons.location_on,
                                                  size: 40,
                                                  color: MyColors.btnColor,
                                                ),
                                                backgroundColor:
                                                    Colors.transparent,
                                                showPlus: true,
                                                internalPadding:
                                                    EdgeInsets.only(
                                                      left: 20,
                                                      right: 20,
                                                      top: 5,
                                                      bottom: 5,
                                                    ),
                                                onTap: () {
                                                  AnalyticsService().trackEvent(
                                                    'Select address - create card',
                                                  );
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/listAddresses',
                                                    arguments: {
                                                      'isEditable': false,
                                                    },
                                                  ).then((value) {
                                                    if (value is Address) {
                                                      viewModel.updateAddress(
                                                        value,
                                                      );
                                                    }
                                                  });
                                                },
                                              ),
                                            )
                                            : GestureDetector(
                                              behavior: HitTestBehavior.opaque,
                                              onTap: () {
                                                AnalyticsService().trackEvent(
                                                  'Select address - create card',
                                                );
                                                Navigator.pushNamed(
                                                  context,
                                                  '/listAddresses',
                                                  arguments: {
                                                    'isEditable': false,
                                                  },
                                                ).then((value) {
                                                  if (value is Address) {
                                                    viewModel.updateAddress(
                                                      value,
                                                    );
                                                  }
                                                });
                                              },

                                              child: Material(
                                                color: MyColors.backgroundColor,
                                                child: ListTile(
                                                  tileColor:
                                                      MyColors.backgroundColor,
                                                  title: Text(
                                                    viewModel
                                                            .addressSelected
                                                            ?.firstName
                                                            ?.toUpperCase() ??
                                                        '',
                                                    style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: getTextColor(
                                                        context,
                                                      ),
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    viewModel
                                                            .addressSelected
                                                            ?.address1 ??
                                                        '',
                                                    style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: getTextColor(
                                                        context,
                                                      ),
                                                    ),
                                                  ),
                                                  trailing: Icon(
                                                    Icons.arrow_forward_ios,
                                                    size: 16,
                                                  ),
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                ),
                                              ),
                                            ),
                                  ),
                              SizedBox(height: 25),
                              Text(
                                'Datos del titular',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Divider(
                                  color: Colors.grey.shade200,
                                  height: 2,
                                ),
                              ),
                              viewModel.customerLoading
                                  ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.grey,
                                      strokeWidth: 1.5,
                                    ),
                                  )
                                  : SizedBox(
                                    height: 60,
                                    child:
                                        viewModel.customer == null
                                            ? Padding(
                                              padding: EdgeInsets.only(top: 10),
                                              child: AddDottedCardButton(
                                                title: 'Seleccionar datos',
                                                icon: Icon(
                                                  Icons.person,
                                                  size: 40,
                                                  color: MyColors.btnColor,
                                                ),
                                                backgroundColor:
                                                    Colors.transparent,
                                                showPlus: true,
                                                internalPadding:
                                                    EdgeInsets.only(
                                                      left: 20,
                                                      right: 20,
                                                      top: 5,
                                                      bottom: 5,
                                                    ),
                                                onTap: () {
                                                  AnalyticsService().trackEvent(
                                                    'Select billing data - create card',
                                                  );
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/listCustomerBilling',
                                                    arguments: {
                                                      'isEditable': false,
                                                      'isForCreditCard': true,
                                                    },
                                                  ).then((value) {
                                                    if (value
                                                        is CustomerBilling) {
                                                      viewModel.updateCustomer(
                                                        value,
                                                      );
                                                    }
                                                  });
                                                },
                                              ),
                                            )
                                            : GestureDetector(
                                              behavior: HitTestBehavior.opaque,

                                              onTap: () {
                                                AnalyticsService().trackEvent(
                                                  'Select billing data - create card',
                                                );
                                                Navigator.pushNamed(
                                                  context,
                                                  '/listCustomerBilling',
                                                  arguments: {
                                                    'isEditable': false,
                                                    'isForCreditCard': true,
                                                  },
                                                ).then((value) {
                                                  if (value
                                                      is CustomerBilling) {
                                                    viewModel.updateCustomer(
                                                      value,
                                                    );
                                                  }
                                                });
                                              },

                                              child: Material(
                                                color: MyColors.backgroundColor,
                                                child: ListTile(
                                                  tileColor:
                                                      MyColors.backgroundColor,
                                                  title: Text(
                                                    '${viewModel.customer?.firstName?.toUpperCase()} ${viewModel.customer?.lastName?.toUpperCase()}',
                                                    style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: getTextColor(
                                                        context,
                                                      ),
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    viewModel
                                                            .customer
                                                            ?.identification ??
                                                        'Seleccione los datos del propietario',
                                                    style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: getTextColor(
                                                        context,
                                                      ),
                                                    ),
                                                  ),
                                                  trailing: Icon(
                                                    Icons.arrow_forward_ios,
                                                    size: 16,
                                                  ),
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                ),
                                              ),
                                            ),
                                  ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.lock_outline,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      "Tus datos es procesado de forma segura por un proveedor certificado. Nosotros no almacenamos los datos de tu tarjeta.",
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w300,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 30),
                              CustomButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  AnalyticsService().trackEvent(
                                    'Register Card Screen - link card',
                                  );
                                  viewModel.validateAndCreateCardUser(context);
                                },
                                label: 'Vincular tarjeta',
                              ),

                              SizedBox(height: 20),
                            ],
                          ),
                        ],
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

class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Formato con espacios cada 4 dígitos
    // final buffer = StringBuffer();
    // for (int i = 0; i < newText.length; i++) {
    //   if (i != 0 && i % 4 == 0) {
    //     buffer.write(' ');
    //   }
    //   buffer.write(newText[i]);
    // }

    final formatted = formatCardNumberText(newText);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class _CardDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 2) {
      text = '${text.substring(0, 2)}/${text.substring(2)}';
    }
    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

