import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:mobile_app_template/components/custom_scaffold.dart';
import 'package:mobile_app_template/components/custom_text_field.dart';
import 'package:mobile_app_template/components/nav_bar_header.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/home/billing/customer/create_edit_customer_billing_data_view_model.dart';
import 'package:mobile_app_template/views/loading/loading_viewmodel.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:provider/provider.dart';

class CreateOrEditCustomerBillingDataScreen extends StatefulWidget {
  final CustomerBilling? customer;
  final bool? setDefault;

  const CreateOrEditCustomerBillingDataScreen({
    Key? key,
    this.customer,
    this.setDefault,
  });

  @override
  CreateOrEditCustomerBillingDataScreenState createState() =>
      CreateOrEditCustomerBillingDataScreenState();
}

class CreateOrEditCustomerBillingDataScreenState
    extends State<CreateOrEditCustomerBillingDataScreen> {
  late CreateOrEditCustomerBillingDataViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = CreateOrEditCustomerBillingDataViewModel();
    if (widget.customer != null) {
      viewModel.updateCustomer(widget.customer!);
    } else if (widget.setDefault == true) {
      viewModel.updateDefault(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = Provider.of<LoadingViewModel>(context);

    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<CreateOrEditCustomerBillingDataViewModel>(
        builder: (context, vm, _) {
          return CustomScaffold(
            useSafeArea: true,
            child: Column(
              children: [
                NavBarHeader(
                  searchBelow: false,
                  showImageApp: false,
                  showSearch: false,
                  showShoppingCart: false,
                  showBackButton: true,
                  children: Center(
                    child: Text(
                      widget.customer != null ? 'Actualizar' : 'Crear',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: MyColors.navBarText,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            top: 20,
                            left: 20,
                            right: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 10,
                            children: [
                              Text(
                                'Ingrese los datos',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 20),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child:
                                        widget.customer == null
                                            ? Material(
                                              color: Colors.transparent,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Tipo',
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
                                                  SizedBox(
                                                    height:
                                                        Platform.isIOS ? 5 : 10,
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 16,
                                                        ),
                                                    width: double.infinity,
                                                    // height: 5,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade300,
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    child: DropdownButtonHideUnderline(
                                                      child: DropdownButton<
                                                        TypeIdentification
                                                      >(
                                                        isExpanded: true,
                                                        dropdownColor:
                                                            MyColors
                                                                .backgroundColor,
                                                        value:
                                                            viewModel
                                                                .typeIdentificationSelected,
                                                        icon: Icon(
                                                          Icons
                                                              .keyboard_arrow_down,
                                                          color: getTextColor(
                                                            context,
                                                          ),
                                                        ),
                                                        items:
                                                            viewModel.typesIdentification.map((
                                                              v,
                                                            ) {
                                                              return DropdownMenuItem(
                                                                value: v,
                                                                child: Text(
                                                                  v.label,
                                                                  style: TextStyle(
                                                                    fontFamily:
                                                                        'Poppins',
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color:
                                                                        getTextColor(
                                                                          context,
                                                                        ),
                                                                  ),
                                                                ),
                                                              );
                                                            }).toList(),
                                                        onChanged:
                                                            (v) => viewModel
                                                                .updateTypeIdentification(
                                                                  v ??
                                                                      TypeIdentification
                                                                          .cedula,
                                                                ),
                                                      ),
                                                    ),
                                                  ),
                                                  if (Platform.isIOS)
                                                    SizedBox(height: 10),
                                                ],
                                              ),
                                            )
                                            : Expanded(
                                              child: CustomTextField(
                                                title: "Tipo",
                                                placeholder: "",
                                                initialValue:
                                                    widget.customer?.type ?? '',
                                                isEnable: false,
                                              ),
                                            ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: CustomTextField(
                                      title: "Identificación",
                                      placeholder: "Identificación",
                                      keyboardType: TextInputType.name,
                                      initialValue:
                                          widget.customer?.identification ?? '',
                                      isEnable: !(widget.customer != null),
                                      onChanged: viewModel.updateIdentification,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      title: "Nombre",
                                      placeholder: "Nombre",
                                      initialValue:
                                          widget.customer?.firstName ?? '',
                                      keyboardType: TextInputType.name,
                                      onChanged: viewModel.updateFirstName,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: CustomTextField(
                                      title: "Apellido",
                                      placeholder: "Apellido",
                                      initialValue:
                                          widget.customer?.lastName ?? '',
                                      keyboardType: TextInputType.name,
                                      onChanged: viewModel.updateLastName,
                                    ),
                                  ),
                                ],
                              ),
                              CustomTextField(
                                title: "Teléfono",
                                placeholder: "Teléfono",
                                initialValue: widget.customer?.phone ?? '',
                                keyboardType: TextInputType.phone,
                                onChanged: viewModel.updatePhone,
                              ),
                              CustomTextField(
                                title: "Correo",
                                placeholder: "Correo",
                                initialValue: widget.customer?.email ?? '',
                                keyboardType: TextInputType.emailAddress,
                                onChanged: viewModel.updateEmail,
                              ),

                              SizedBox(height: 20),
                              CustomButton(
                                onPressed:
                                    () => viewModel.saveCustomerBilling(
                                      context,
                                      loading,
                                    ),
                                label:
                                    widget.customer != null
                                        ? 'Actualizar datos'
                                        : 'Guardar datos',
                              ),
                            ],
                          ),
                        ),
                      ],
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

