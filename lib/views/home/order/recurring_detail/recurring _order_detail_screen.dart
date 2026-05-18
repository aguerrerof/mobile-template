import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/components/check_card.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:mobile_app_template/components/custom_flushbar.dart';
import 'package:mobile_app_template/components/custom_scaffold.dart';
import 'package:mobile_app_template/components/selection_modal_widget.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/utils/card_functions.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/home/order/detail/order_detail_screen.dart';
import 'package:mobile_app_template/views/home/order/recurring_detail/components/DateAutoShipCard.dart';
import 'package:mobile_app_template/views/home/order/recurring_detail/components/recurring_unpaid_order_banner.dart';
import 'package:mobile_app_template/views/home/order/recurring_detail/components/productAutoShipCard.dart';
import 'package:mobile_app_template/views/home/order/recurring_detail/recurring_order_detail_view_model.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class RecurringOrderScreen extends StatefulWidget {
  final RecurringOrder? order;

  const RecurringOrderScreen({Key? key, required this.order});

  @override
  RecurringOrderScreenState createState() => RecurringOrderScreenState();
}

class RecurringOrderScreenState extends State<RecurringOrderScreen> {
  late RecurringOrderDetailViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = RecurringOrderDetailViewModel();
    viewModel.updateOrder(widget.order);
    // viewModel.fetchUser();
    // viewModel.fetchFrequencies();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<RecurringOrderDetailViewModel>(
        builder: (context, vm, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.messageError != null) {
              showCustomFlushbar(
                context,
                message: viewModel.messageError ?? '',
              );
              viewModel.updateMessage(null);
            }

            if (viewModel.showDeleteDialog) {
              viewModel.updateDeleteDialogStatus(false);
              showDialog(
                context: context,
                builder:
                    (ctx) => AlertDialog(
                      backgroundColor: MyColors.backgroundColor,
                      title: Text(
                        "Eliminar Auto Envío",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          color: getTextColor(context),
                        ),
                      ),
                      content: Text(
                        "¿Vas a cancelar tu Auto Envío? ¡Tus peludos amigos podrían quedarse sin croquetas… y no estarán felices!",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          color: getTextColor(context),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            "Cancelar",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              color: getTextColor(context),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            viewModel.deleteOrderRecurrence(context);
                          },
                          child: Text(
                            "Eliminar",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              color: getTextColor(context),
                            ),
                          ),
                        ),
                      ],
                    ),
              );
            }
          });

          return CustomScaffold(
            cupertinoNavigationBar: CupertinoNavigationBar(
              backgroundColor: Colors.transparent,
              leading: CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.back),
                onPressed: () => Navigator.pop(context),
              ),
              middle: Text(
                'Auto Envío',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // trailing: CupertinoButton(
              //   padding: EdgeInsets.zero,
              //   child: const Icon(CupertinoIcons.ellipsis_vertical),
              //   onPressed: () => viewModel.showMenuCupertino(context),
              // ),
            ),
            materialNavigationBar: AppBar(
              leading: BackButton(onPressed: () => Navigator.pop(context)),
              title: Text(
                'Auto Envío',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              actions: [
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert),
                  onSelected: (String value) {
                    if (value == 'opcion1') {
                      print('deberia mostrar');
                      viewModel.updateDeleteDialogStatus(true);
                    }
                  },
                  itemBuilder:
                      (BuildContext context) => [
                        PopupMenuItem(
                          value: 'opcion1',
                          child: Text(
                            'Eliminar orden',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // summaryRow(
                  //   'Próxima entrega',
                  //   formatDateOrder(viewModel.order!.nextChargeDate),
                  //   padding: EdgeInsets.all(0),
                  //   isResume: true,
                  //   textSize: 16,
                  //   context,
                  // ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsetsGeometry.all(5),
                        child: Icon(
                          Icons.sync,
                          color: MyColors.btnColor,
                          size: 18,
                        ),
                      ),
                      Text(
                        'Frecuencia de envío',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 5),
                  Material(
                    color: MyColors.backgroundColor,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: MyColors.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<Frequency>(
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        initialValue: vm.frequencySelected,
                        dropdownColor: MyColors.backgroundColor,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.grey,
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          color: getTextColor(context),
                        ),
                        items:
                            vm.frequencies.map((opcion) {
                              return DropdownMenuItem<Frequency>(
                                value: opcion,
                                child: Text(opcion.name),
                              );
                            }).toList(),
                        onChanged: (value) {
                          vm.updateFrecuency(value);
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 15),
                  if (!viewModel.order!.hasUnpaidOrder)
                    DateAutoShipCard(
                      title: "Próxima entrega",
                      dateText:
                          viewModel.order!.nextDeliveryDate.isNotEmpty
                              ? formatDateOrder(
                                viewModel.order!.nextDeliveryDate,
                                null,
                              )
                              : '--',
                      title2: "Próximo cobro",
                      dateText2:
                          viewModel.order!.nextChargeDate.isNotEmpty
                              ? formatDateOrder(
                                viewModel.order!.nextChargeDate,
                                null,
                              )
                              : '--',
                    )
                  else
                    RecurringUnpaidOrderBanner(
                      unpaidOrderId: viewModel.order!.unpaidOrderId,
                    ),

                  //   DropdownButton<Frequency>(
                  //     value: vm.frequencySelected,
                  //     hint: Text("Selecciona una opción"),
                  //     items:
                  //         vm.frequencies
                  //             .map(
                  //               (item) => DropdownMenuItem(
                  //                 value: item,
                  //                 child: Text(item.name),
                  //               ),
                  //             )
                  //             .toList(),
                  //     onChanged: (value) {
                  //       vm.updateFrecuency(value);
                  //     },
                  //   ),
                  // ),

                  // CheckCardWidget(
                  //   tapGesture: () {},
                  //   showAlwaysSubtitle: false,
                  //   backgroundColor: MyColors.backgroundColor,
                  //   borderColor: Colors.transparent,
                  //   showCheck: false,
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Text(
                  //         viewModel.order?.frequency ?? '',
                  //         style: TextStyle(
                  //           fontFamily: 'Poppins',
                  //           fontWeight: FontWeight.w500,
                  //           color: getTextColor(context),
                  //           fontSize: 14,
                  //         ),
                  //       ),
                  //       const SizedBox(height: 8),
                  //       Row(
                  //         children: [
                  //           Spacer(),
                  //           SizedBox(
                  //             width: 100,
                  //             child: CustomButton(
                  //               height: 30,
                  //               type: CustomButtonType.outline,
                  //               onPressed: () => vm.showFrecuencyModal(context),
                  //               label: 'Cambiar',
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsetsGeometry.all(5),
                        child: Icon(
                          Icons.location_on_outlined,
                          color: MyColors.btnColor,
                          size: 18,
                        ),
                      ),
                      Text(
                        'Dirección de envío',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: getTextColor(context),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 5),
                  viewModel.addressLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.grey,
                          strokeWidth: 1.5,
                        ),
                      )
                      : CheckCardWidget(
                        tapGesture: () {},
                        showAlwaysSubtitle: false,
                        backgroundColor: MyColors.backgroundColor,
                        borderColor: Colors.transparent,
                        showCheck: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              viewModel.addressSelected?.firstName ?? '',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                color: getTextColor(context),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              viewModel.addressSelected?.address1 ?? '',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                color: getTextColor(context),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Spacer(),
                                SizedBox(
                                  width: 115,
                                  child: CustomButton(
                                    height: 30,
                                    type: CustomButtonType.outline,
                                    onPressed:
                                        () => Navigator.pushNamed(
                                          context,
                                          '/listAddresses',
                                          arguments: {'isEditable': false},
                                        ).then((value) {
                                          if (value is Address) {
                                            viewModel.updateAddress(
                                              value,
                                              true,
                                            );
                                          }
                                        }),
                                    label: 'Cambiar',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                  SizedBox(height: 15),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsetsGeometry.all(5),
                        child: Icon(
                          Icons.credit_card,
                          color: MyColors.btnColor,
                          size: 18,
                        ),
                      ),
                      Text(
                        'Método de pago',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: getTextColor(context),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),
                  CheckCardWidget(
                    tapGesture: () {},
                    showAlwaysSubtitle: false,
                    backgroundColor: MyColors.backgroundColor,
                    borderColor: Colors.transparent,
                    showCheck: false,
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              viewModel.card?.cardInfo ?? '- Seleccione',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: getTextColor(context),
                              ),
                            ),
                            Text(
                              viewModel.card?.cardIssuer ?? '',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: getTextColor(context),
                              ),
                            ),
                          ],
                        ),

                        Spacer(),
                        SizedBox(
                          width: 115,
                          child: CustomButton(
                            height: 30,
                            type: CustomButtonType.outline,
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/listCreditCard',
                                arguments: {'selectionable': true},
                              ).then((newCard) {
                                if (newCard is CardDetail) {
                                  viewModel.updateCard(newCard);
                                }
                              });
                            },
                            label: 'Cambiar',
                          ),
                        ),
                      ],
                    ),
                  ),

                  // DateAutoShipCard(
                  //   title: "Próximo cobro",
                  //   dateText: formatDateOrder(viewModel.order!.nextChargeDate,null),
                  // ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Divider(color: Colors.grey.shade200, height: 2),
                  ),

                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsetsGeometry.all(5),
                        child: SvgPicture.asset(
                          'assets/icons/package_2.svg',
                          fit: BoxFit.cover,
                          width: 20,
                          height: 20,
                          colorFilter: ColorFilter.mode(
                            MyColors.btnColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      Text(
                        'Productos (${vm.order?.lineItems.length})',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: getTextColor(context),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: viewModel.order?.lineItems.length ?? 0,
                    itemBuilder: (context, index) {
                      final item = viewModel.order?.lineItems[index];
                      return ProductAutoShipCard(
                        title: item?.title ?? '',
                        priceText: '\$${item?.price.toStringAsFixed(2)}',
                        quantity: item?.quantity ?? 1,
                        onRemove:
                            () => {
                              showDialog(
                                context: context,
                                builder:
                                    (ctx) => AlertDialog(
                                      backgroundColor: MyColors.backgroundColor,
                                      title: Text(
                                        "Quitar artículo",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                          color: getTextColor(context),
                                        ),
                                      ),
                                      content: Text(
                                        "¿Estás seguro de quitar el artículo?",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Poppins',
                                          color: getTextColor(context),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: Text(
                                            "Cancelar",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Poppins',
                                              color: getTextColor(context),
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            viewModel.deleteItem(
                                              context,
                                              index,
                                            );
                                            Navigator.pop(ctx);
                                          },
                                          child: Text(
                                            "Quitar",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Poppins',
                                              color: getTextColor(context),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                              ),
                            },
                      );

                      // Container(
                      //   margin: EdgeInsets.symmetric(vertical: 8),
                      //   child: Padding(
                      //     padding: const EdgeInsets.symmetric(vertical: 5.0),
                      //     child: Column(
                      //       children: [
                      //         Row(
                      //           children: [
                      //             ClipRRect(
                      //               borderRadius: BorderRadius.circular(10),
                      //               child: Image.network(
                      //                 item?.imageUrl ?? '',
                      //                 fit: BoxFit.contain,
                      //                 width: 80,
                      //                 height: 100,
                      //                 loadingBuilder: (
                      //                   context,
                      //                   child,
                      //                   loadingProgress,
                      //                 ) {
                      //                   if (loadingProgress == null) {
                      //                     return child;
                      //                   } else {
                      //                     return const Center(
                      //                       child: CircularProgressIndicator(
                      //                         color: Colors.grey,
                      //                         strokeWidth: 1.5,
                      //                       ),
                      //                     );
                      //                   }
                      //                 },
                      //                 errorBuilder: (
                      //                   context,
                      //                   error,
                      //                   stackTrace,
                      //                 ) {
                      //                   return const Icon(Icons.error);
                      //                 },
                      //               ),
                      //             ),
                      //             SizedBox(width: 12),
                      //             Expanded(
                      //               child: Column(
                      //                 crossAxisAlignment:
                      //                     CrossAxisAlignment.start,
                      //                 children: [
                      //                   Text(
                      //                     item?.title ?? '',
                      //                     style: TextStyle(
                      //                       fontWeight: FontWeight.w500,
                      //                       fontSize: 15,
                      //                       fontFamily: 'Poppins',
                      //                       color: getTextColor(context),
                      //                     ),
                      //                   ),
                      //                   SizedBox(height: 4),
                      //                   Text(
                      //                     '\$${item?.price.toStringAsFixed(2)}',
                      //                     style: TextStyle(
                      //                       fontFamily: 'Poppins',
                      //                       fontSize: 14,
                      //                       fontWeight: FontWeight.w400,
                      //                       color: Colors.red,
                      //                     ),
                      //                   ),
                      //                   SizedBox(height: 5),
                      //                   Row(
                      //                     children: [
                      //                       Spacer(),
                      //                       Container(
                      //                         decoration: BoxDecoration(
                      //                           color: Colors.white,
                      //                           borderRadius: BorderRadius.all(
                      //                             Radius.circular(12.5),
                      //                           ),
                      //                           border: Border.all(
                      //                             color: getTextColor(context)!,
                      //                           ),
                      //                         ),

                      //                         child: SizedBox(
                      //                           height: 25,
                      //                           width: 120,
                      //                           child: Row(
                      //                             crossAxisAlignment:
                      //                                 CrossAxisAlignment.center,
                      //                             mainAxisAlignment:
                      //                                 MainAxisAlignment
                      //                                     .spaceBetween,
                      //                             children: [
                      //                               CustomButton(
                      //                                 onPressed: () {
                      //                                   viewModel
                      //                                       .changeQuantity(
                      //                                         item!,
                      //                                         -1,
                      //                                         context,
                      //                                       );
                      //                                 },
                      //                                 icon: Icon(
                      //                                   Icons
                      //                                       .remove_circle_outline,
                      //                                   color: getTextColor(
                      //                                     context,
                      //                                   ),
                      //                                 ),
                      //                                 height: 20,
                      //                                 widht: 40,
                      //                                 paddingHorizontal: 0,
                      //                                 backgroundColor:
                      //                                     Colors.transparent,
                      //                               ),
                      //                               Text(
                      //                                 '${item?.quantity}',
                      //                                 style: TextStyle(
                      //                                   fontFamily: 'Poppins',
                      //                                   fontSize: 16,
                      //                                   fontWeight:
                      //                                       FontWeight.w500,
                      //                                   color: getTextColor(
                      //                                     context,
                      //                                   ),
                      //                                 ),
                      //                               ),
                      //                               CustomButton(
                      //                                 onPressed: () {
                      //                                   viewModel
                      //                                       .changeQuantity(
                      //                                         item!,
                      //                                         1,
                      //                                         context,
                      //                                       );
                      //                                 },
                      //                                 icon: Icon(
                      //                                   Icons
                      //                                       .add_circle_outline,
                      //                                   color: getTextColor(
                      //                                     context,
                      //                                   ),
                      //                                 ),
                      //                                 height: 20,
                      //                                 widht: 40,
                      //                                 paddingHorizontal: 0,
                      //                                 backgroundColor:
                      //                                     Colors.transparent,
                      //                               ),
                      //                             ],
                      //                           ),
                      //                         ),
                      //                       ),
                      //                     ],
                      //                   ),
                      //                   SizedBox(height: 20),
                      //                   Row(
                      //                     children: [
                      //                       Spacer(),
                      //                       CustomButton(
                      //                         height: 30,
                      //                         widht: 120,
                      //                         type: CustomButtonType.outline,
                      //                         onPressed:
                      //                             () => {
                      //                               showDialog(
                      //                                 context: context,
                      //                                 builder:
                      //                                     (ctx) => AlertDialog(
                      //                                       backgroundColor:
                      //                                           MyColors
                      //                                               .backgroundColor,
                      //                                       title: Text(
                      //                                         "Quitar artículo",
                      //                                         style: TextStyle(
                      //                                           fontSize: 16,
                      //                                           fontFamily:
                      //                                               'Poppins',
                      //                                           color:
                      //                                               getTextColor(
                      //                                                 context,
                      //                                               ),
                      //                                         ),
                      //                                       ),
                      //                                       content: Text(
                      //                                         "¿Estás seguro de quitar el artículo?",
                      //                                         style: TextStyle(
                      //                                           fontSize: 14,
                      //                                           fontFamily:
                      //                                               'Poppins',
                      //                                           color:
                      //                                               getTextColor(
                      //                                                 context,
                      //                                               ),
                      //                                         ),
                      //                                       ),
                      //                                       actions: [
                      //                                         TextButton(
                      //                                           onPressed:
                      //                                               () =>
                      //                                                   Navigator.pop(
                      //                                                     ctx,
                      //                                                   ),
                      //                                           child: Text(
                      //                                             "Cancelar",
                      //                                             style: TextStyle(
                      //                                               fontSize:
                      //                                                   14,
                      //                                               fontFamily:
                      //                                                   'Poppins',
                      //                                               color:
                      //                                                   getTextColor(
                      //                                                     context,
                      //                                                   ),
                      //                                             ),
                      //                                           ),
                      //                                         ),
                      //                                         TextButton(
                      //                                           onPressed: () {
                      //                                             viewModel
                      //                                                 .deleteItem(
                      //                                                   context,
                      //                                                   index,
                      //                                                 );
                      //                                             Navigator.pop(
                      //                                               ctx,
                      //                                             );
                      //                                           },
                      //                                           child: Text(
                      //                                             "Quitar",
                      //                                             style: TextStyle(
                      //                                               fontSize:
                      //                                                   14,
                      //                                               fontFamily:
                      //                                                   'Poppins',
                      //                                               color:
                      //                                                   getTextColor(
                      //                                                     context,
                      //                                                   ),
                      //                                             ),
                      //                                           ),
                      //                                         ),
                      //                                       ],
                      //                                     ),
                      //                               ),
                      //                             },
                      //                         label: 'Quitar',
                      //                       ),
                      //                     ],
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //           ],
                      //         ),

                      //         Padding(
                      //           padding: const EdgeInsets.only(top: 24),
                      //           child: Divider(
                      //             color: Colors.grey.shade200,
                      //             height: 2,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // );
                    },
                  ),

                  const SizedBox(height: 26),
                  CustomButton(
                    label: 'Guardar cambios',
                    onPressed: () => viewModel.validate(context),
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    label: 'Cancelar Auto Envío',
                    type: CustomButtonType.outline,
                    onPressed: () => viewModel.updateDeleteDialogStatus(true),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

