import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/analitics_service.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:mobile_app_template/components/custom_scaffold.dart';
import 'package:mobile_app_template/components/nav_bar_header.dart';
import 'package:mobile_app_template/components/notFound/empty_list_widget.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/home/billing/customer/customer_billing_data_list_view_model.dart';
import 'package:mobile_app_template/views/loading/loading_viewmodel.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:provider/provider.dart';

class CustomerBillingDataListScreen extends StatefulWidget {
  final bool canEdit;
  final bool? isForCreditCard;

  const CustomerBillingDataListScreen({
    Key? key,
    required this.canEdit,
    this.isForCreditCard,
  });

  @override
  CustomerBillingDataListScreenState createState() =>
      CustomerBillingDataListScreenState();
}

class CustomerBillingDataListScreenState
    extends State<CustomerBillingDataListScreen> {
  late CustomerBillingDataListViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = CustomerBillingDataListViewModel();
    viewModel.fetchCustomersBilling();
  }

  Future<void> _handleRefresh() async {
    viewModel.fetchCustomersBilling();
  }

  @override
  Widget build(BuildContext context) {
    final loading = Provider.of<LoadingViewModel>(context);

    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<CustomerBillingDataListViewModel>(
        builder: (context, vm, _) {
          return CustomScaffold(
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
                      'Datos de facturación',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: MyColors.navBarText,
                      ),
                    ),
                  ),
                ),
                viewModel.isLoading
                    ? const Padding(
                      padding: EdgeInsetsGeometry.only(top: 20),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.grey,
                          strokeWidth: 1.5,
                        ),
                      ),
                    )
                    : viewModel.customersBilling.isEmpty
                    ? emptyView(
                      context,
                      'Aún no has guardado tus datos de facturación.',
                      'Agrégalos para poder emitir tus facturas correctamente.',
                      null,
                      "Agregar datos",
                      () {
                        Navigator.pushNamed(
                          context,
                          '/customerBilling',
                          arguments: {
                            'setDefault': viewModel.customersBilling.isEmpty,
                          },
                        ).then((value) {
                          viewModel.fetchCustomersBilling();
                        });
                      },
                      null,
                      null,
                    )
                    : Expanded(
                      child: Stack(
                        children: [
                          RefreshIndicator(
                            onRefresh: _handleRefresh,
                            backgroundColor: MyColors.backgroundColor,
                            color: MyColors.btnColor,
                            child: CustomScrollView(
                              slivers: [
                                SliverToBoxAdapter(child: SizedBox(height: 24)),
                                if (!widget.canEdit)
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        bottom: 20,
                                      ),
                                      child: Text(
                                        'Seleccione sus datos',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final item =
                                          viewModel.customersBilling[index];

                                      return GestureDetector(
                                        onTap: () {
                                          if (!widget.canEdit) {
                                            Navigator.pop(context, item);
                                          }
                                        },
                                        child: Card(
                                          color: MyColors.backgroundColor,
                                          margin: EdgeInsets.only(
                                            top: 10,
                                            left: 20,
                                            right: 20,
                                            bottom: 5,
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                RichText(
                                                  textAlign: TextAlign.left,
                                                  text: TextSpan(
                                                    text:
                                                        '${item.firstName} ${item.lastName}'
                                                            .toUpperCase(),
                                                    style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14,
                                                      color: getTextColor(
                                                        context,
                                                      ),
                                                    ),
                                                    children: [
                                                      if (item.isDefault)
                                                        TextSpan(
                                                          text: ' - Principal',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Poppins',
                                                            fontSize: 14,
                                                            color: getTextColor(
                                                              context,
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),

                                                SizedBox(height: 8),
                                                Text(
                                                  item.identification ?? '',
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 14,
                                                    color: getTextColor(
                                                      context,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  item.email ?? '',
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 14,
                                                    color: getTextColor(
                                                      context,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'Teléfono: ${item.phone}',
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 14,
                                                    color: getTextColor(
                                                      context,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                if (widget.canEdit)
                                                  Wrap(
                                                    spacing: 5,
                                                    runSpacing: 8,
                                                    children: [
                                                      Row(
                                                        spacing: 5,
                                                        children: [
                                                          CustomButton(
                                                            height: 30,
                                                            type:
                                                                CustomButtonType
                                                                    .outline,
                                                            onPressed: () {
                                                              Navigator.pushNamed(
                                                                context,
                                                                '/customerBilling',
                                                                arguments: {
                                                                  'customer':
                                                                      item,
                                                                },
                                                              ).then((value) {
                                                                viewModel
                                                                    .fetchCustomersBilling();
                                                              });
                                                            },
                                                            label: 'Editar',
                                                          ),
                                                          CustomButton(
                                                            height: 30,
                                                            type:
                                                                CustomButtonType
                                                                    .outline,
                                                            onPressed: () {
                                                              if (Platform
                                                                  .isIOS) {
                                                                showCupertinoDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (
                                                                        ctx,
                                                                      ) => CupertinoAlertDialog(
                                                                        title: const Text(
                                                                          "Eliminar registro de facturación ",
                                                                        ),
                                                                        content:
                                                                            const Text(
                                                                              "¿Seguro que deseas eliminar este dato de facturación? La misma identificación, RUC o pasaporte no podrá reutilizarse.",
                                                                            ),
                                                                        actions: [
                                                                          CupertinoDialogAction(
                                                                            child: Text(
                                                                              "Cancelar",
                                                                              style: TextStyle(
                                                                                color:
                                                                                    CupertinoTheme.of(
                                                                                              ctx,
                                                                                            ).brightness ==
                                                                                            Brightness.dark
                                                                                        ? CupertinoColors.white
                                                                                        : CupertinoTheme.of(
                                                                                          ctx,
                                                                                        ).primaryColor,
                                                                              ),
                                                                            ),
                                                                            onPressed:
                                                                                () => Navigator.pop(
                                                                                  ctx,
                                                                                ),
                                                                          ),
                                                                          CupertinoDialogAction(
                                                                            isDestructiveAction:
                                                                                true,
                                                                            onPressed: () {
                                                                              Navigator.pop(
                                                                                ctx,
                                                                              );
                                                                              viewModel.deleteCustomerBilling(
                                                                                context,
                                                                                loading,
                                                                                item,
                                                                                index,
                                                                              );
                                                                            },
                                                                            child: const Text(
                                                                              "Eliminar",
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                );
                                                              } else {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (
                                                                        ctx,
                                                                      ) => AlertDialog(
                                                                        backgroundColor:
                                                                            MyColors.backgroundColor,
                                                                        title: Text(
                                                                          "Eliminar registro de facturación ",
                                                                          style: TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontFamily:
                                                                                'Poppins',
                                                                            color: getTextColor(
                                                                              context,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        content: Text(
                                                                          "¿Seguro que deseas eliminar este dato de facturación? La misma identificación, RUC o pasaporte no podrá reutilizarse.",
                                                                          style: TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontFamily:
                                                                                'Poppins',
                                                                            color: getTextColor(
                                                                              context,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        actions: [
                                                                          TextButton(
                                                                            onPressed:
                                                                                () => Navigator.pop(
                                                                                  ctx,
                                                                                ),
                                                                            child: Text(
                                                                              "Cancelar",
                                                                              style: TextStyle(
                                                                                fontSize:
                                                                                    14,
                                                                                fontFamily:
                                                                                    'Poppins',
                                                                                color: getTextColor(
                                                                                  context,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          TextButton(
                                                                            onPressed: () {
                                                                              Navigator.pop(
                                                                                ctx,
                                                                              );
                                                                              viewModel.deleteCustomerBilling(
                                                                                context,
                                                                                loading,
                                                                                item,
                                                                                index,
                                                                              );
                                                                            },
                                                                            child: Text(
                                                                              "Eliminar",
                                                                              style: TextStyle(
                                                                                fontSize:
                                                                                    14,
                                                                                fontFamily:
                                                                                    'Poppins',
                                                                                color: getTextColor(
                                                                                  context,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                );
                                                              }
                                                            },
                                                            label: 'Eliminar',
                                                          ),
                                                        ],
                                                      ),
                                                      if (!item.isDefault)
                                                        CustomButton(
                                                          height: 30,
                                                          type:
                                                              CustomButtonType
                                                                  .outline,
                                                          onPressed: () {
                                                            viewModel
                                                                .updateCustomerBilling(
                                                                  context,
                                                                  loading,
                                                                  item,
                                                                  true,
                                                                );
                                                          },
                                                          label:
                                                              'Definir como principal',
                                                        ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    childCount:
                                        viewModel.customersBilling.length,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              color: MyColors.backgroundColor,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: 20,
                                  left: 20,
                                  top: 5,
                                  bottom: 5,
                                ),
                                child: CustomButton(
                                  onPressed: () {
                                    AnalyticsService().trackEvent(
                                      'Add billing data - list',
                                    );
                                    Navigator.pushNamed(
                                      context,
                                      '/customerBilling',
                                      arguments: {
                                        'setDefault':
                                            viewModel.customersBilling.isEmpty,
                                      },
                                    ).then((value) {
                                      viewModel.fetchCustomersBilling();
                                    });
                                  },

                                  label: 'Agregar datos',
                                ),
                              ),
                            ),
                          ),
                        ],
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

