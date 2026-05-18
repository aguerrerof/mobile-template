import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app_template/components/check_card.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:mobile_app_template/components/custom_flushbar.dart';
import 'package:mobile_app_template/components/custom_scaffold.dart';
import 'package:mobile_app_template/components/horizontal_stepper_widget.dart';
import 'package:mobile_app_template/components/nav_bar_header.dart';
import 'package:mobile_app_template/components/page_sheet/bottom_page_sheet.dart';
import 'package:mobile_app_template/components/vertical_steeper_widget.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/utils/card_functions.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/home/order/detail/order_detail_view_model.dart';
import 'package:mobile_app_template/views/home/order/recurring_detail/components/productAutoShipCard.dart';
import 'package:mobile_app_template/views/loading/loading_viewmodel.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatefulWidget {
  final Order? order;

  const OrderScreen({Key? key, required this.order});

  @override
  OrderScreenState createState() => OrderScreenState();
}

class OrderScreenState extends State<OrderScreen> {
  late OrderDetailViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = OrderDetailViewModel();
    viewModel.updateOrder(widget.order);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<OrderDetailViewModel>(
        builder: (context, vm, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final loading = Provider.of<LoadingViewModel>(
              context,
              listen: false,
            );
            if (vm.isLoading) {
              loading.show();
            } else {
              loading.hide();
            }

            if (vm.messageError != null) {
              showCustomFlushbar(context, message: vm.messageError ?? '');
              vm.updateMessage(null);
            }

            if (vm.goBack) {
              Navigator.pop(context);
            }

            if (vm.showTrakingDetail) {
              viewModel.updateShowTrackingDetail(false);
              CustomBottomSheet.show(
                context: context,
                title: 'Seguimiento del paquete',
                initialChildSize: 0.75,
                child: Flexible(
                  child: SingleChildScrollView(
                    child: VerticalStepper(
                      steps: vm.order!.fulfillment!.getStepsAvailable(),
                      showPrev: false,
                    ),
                  ),
                ),
              );
            }
          });

          return CustomScaffold(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 50),
                      if (vm.order?.extra != null &&
                          vm.order!.extra!.isNotEmpty)
                        Padding(
                          padding: EdgeInsetsGeometry.only(bottom: 20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              vm.order?.extra ??
                                  "Existió un error al realizar el cobro, verifica tu método de pago o intenta con otro.",
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),

                      if (viewModel.order?.createAt != null)
                        summaryRow(
                          'Orden realizada',
                          formatDateOrder(viewModel.order!.createAt!, null),
                          padding: EdgeInsets.all(0),
                          isResume: true,
                          textSize: 16,
                          textSizeValue: 14,
                          context,
                        ),
                      summaryRow(
                        'Orden #',
                        '${viewModel.order?.order?.orderNumber}',
                        padding: EdgeInsets.all(0),
                        isResume: true,
                        textSize: 16,
                        textSizeValue: 14,
                        context,
                      ),
                      summaryRow(
                        'Estado',
                        viewModel.order?.order?.financialStatus == 'paid'
                            ? 'Pagado'
                            : 'Pendiente de cobro',
                        padding: EdgeInsets.all(0),
                        isResume: true,
                        valueColor:
                            viewModel.order?.order?.financialStatus != 'paid'
                                ? Colors.red
                                : hexToColor('367C48'),
                        textSize: 16,
                        textSizeValue: 14,
                        context,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Divider(color: Colors.grey.shade200, height: 2),
                      ),

                      Text(
                        'Método de pago utilizado',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      viewModel.order?.order?.financialStatus == 'paid'
                          ? Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Text(
                              "${viewModel.payment?.cardIssuer} - ${viewModel.payment?.cardInfo}",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                              ),
                            ),
                          )
                          : Padding(
                            padding: EdgeInsetsGeometry.only(top: 10),
                            child: CheckCardWidget(
                              tapGesture: () {},
                              showAlwaysSubtitle: false,
                              backgroundColor: MyColors.backgroundColor,
                              borderColor: Colors.transparent,
                              showCheck: false,
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        viewModel.payment?.cardInfo ??
                                            '- Seleccione',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          color: getTextColor(context),
                                        ),
                                      ),
                                      Text(
                                        viewModel.payment?.cardIssuer ?? '',
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
                                    width: 100,
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
                          ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Divider(color: Colors.grey.shade200, height: 2),
                      ),

                      if (vm.order?.fulfillment != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Seguimiento del paquete',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Card(
                                color: MyColors.backgroundColor,
                                child: Padding(
                                  padding: EdgeInsetsGeometry.all(15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        spacing: 5,
                                        children: [
                                          Image.asset(
                                            height: 25,
                                            'assets/images/app_icon.png',
                                            fit: BoxFit.cover,
                                          ),
                                          Text(
                                            vm
                                                    .order
                                                    ?.fulfillment
                                                    ?.logisticProvider
                                                    ?.name ??
                                                'Courier',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                              color: getTextColor(context),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      if (vm
                                              .order
                                              ?.fulfillment
                                              ?.trackingNumber !=
                                          null)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'N. de seguimiento',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),

                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  vm
                                                          .order
                                                          ?.fulfillment
                                                          ?.trackingNumber ??
                                                      '',
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14,
                                                    color: getTextColor(
                                                      context,
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      height: 35,
                                                      width: 35,
                                                      child: IconButton(
                                                        icon: Icon(
                                                          Icons.copy,
                                                          color: getTextColor(
                                                            context,
                                                          ),
                                                          size: 18,
                                                        ),
                                                        onPressed: () async {
                                                          await Clipboard.setData(
                                                            ClipboardData(
                                                              text:
                                                                  vm
                                                                      .order
                                                                      ?.fulfillment
                                                                      ?.trackingNumber ??
                                                                  '',
                                                            ),
                                                          );
                                                          if (!context.mounted)
                                                            return;
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                'Texto copiado al portapapeles',
                                                              ),
                                                              duration:
                                                                  Duration(
                                                                    seconds: 2,
                                                                  ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    if (vm
                                                            .order
                                                            ?.fulfillment
                                                            ?.trackingUrl !=
                                                        null)
                                                      SizedBox(
                                                        height: 35,
                                                        width: 35,
                                                        child: IconButton(
                                                          icon: Icon(
                                                            Icons
                                                                .search_rounded,
                                                            color: getTextColor(
                                                              context,
                                                            ),
                                                            size: 18,
                                                          ),
                                                          onPressed: () {
                                                            openUrl(
                                                              vm
                                                                      .order
                                                                      ?.fulfillment
                                                                      ?.trackingUrl ??
                                                                  '',
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (vm.order?.fulfillment?.steps != null)
                              Column(
                                children: [
                                  SizedBox(height: 15),
                                  VerticalStepper(
                                    steps:
                                        vm.order!.fulfillment!
                                                    .getStepsAvailable()
                                                    .length >
                                                3
                                            ? vm.order!.fulfillment!
                                                .getStepsAvailable()
                                                .sublist(0, 2)
                                            : vm.order!.fulfillment!
                                                .getStepsAvailable(),
                                    showPrev: true,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomButton(
                                        onPressed: () {
                                          vm.updateShowTrackingDetail(true);
                                        },
                                        label: 'Ver más',
                                        type: CustomButtonType.text,
                                        icon: Icon(
                                          Icons.keyboard_arrow_down,
                                          color: MyColors.btnColor,
                                          size: 18,
                                        ),
                                      ),
                                      Spacer(),
                                    ],
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                    ),
                                    child: Divider(
                                      color: Colors.grey.shade200,
                                      height: 2,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),

                      Text(
                        'Tus productos (${vm.order?.order?.lineItems.length})',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      // SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount:
                            viewModel.order?.order?.lineItems.length ?? 0,
                        itemBuilder: (context, index) {
                          final item = viewModel.order?.order?.lineItems[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: ProductAutoShipCard(
                              title: item?.title ?? "",
                              priceText: '\$${item?.price.toStringAsFixed(2)}',
                              quantity: item?.quantity ?? 1,
                            ),
                          );
                          // return Container(
                          //   margin: EdgeInsets.symmetric(vertical: 8),
                          //   child: Padding(
                          //     padding: const EdgeInsets.symmetric(
                          //       vertical: 5.0,
                          //     ),
                          //     child: Column(
                          //       children: [
                          //         Row(
                          //           children: [
                          //             ClipRRect(
                          //               borderRadius: BorderRadius.circular(10),
                          //               child: Image.network(
                          //                 item?.image ?? '',
                          //                 fit: BoxFit.contain,
                          //                 width: 80,
                          //                 height: 70,
                          //                 loadingBuilder: (
                          //                   context,
                          //                   child,
                          //                   loadingProgress,
                          //                 ) {
                          //                   if (loadingProgress == null) {
                          //                     return child;
                          //                   } else {
                          //                     return const Center(
                          //                       child:
                          //                           CircularProgressIndicator(
                          //                             color: Colors.grey,
                          //                             strokeWidth: 1.5,
                          //                           ),
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
                          //                       fontSize: 14,
                          //                       fontFamily: 'Poppins',
                          //                     ),
                          //                   ),
                          //                   Text(
                          //                     '\$${item?.price.toStringAsFixed(2)}',
                          //                     style: TextStyle(
                          //                       fontFamily: 'Poppins',
                          //                       fontSize: 14,
                          //                       fontWeight: FontWeight.w400,
                          //                       color: Colors.red,
                          //                     ),
                          //                   ),
                          //                   Text(
                          //                     'Cantidad: ${item?.quantity}',
                          //                     style: TextStyle(
                          //                       fontFamily: 'Poppins',
                          //                       fontSize: 14,
                          //                       fontWeight: FontWeight.w400,
                          //                     ),
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
                      SizedBox(height: 16),
                      Text(
                        'Dirección de envío',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 5),

                      Text(
                        viewModel.order?.order?.shippingAddress?.firstName ??
                            '',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        viewModel.order?.order?.shippingAddress?.address1 ?? '',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Divider(color: Colors.grey.shade200, height: 2),
                      ),
                      Text(
                        'Resumen de la orden',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),

                      summaryRow(
                        'Subtotal:',
                        '\$${viewModel.order?.order?.subtotalPrice ?? '0.0'}',
                        padding: EdgeInsets.only(top: 10),
                        textSize: 14,
                        textSizeValue: 14,
                        context,
                      ),
                      summaryRow(
                        'Costo de envío:',
                        '\$${viewModel.order?.order?.totalShippingPrice ?? '0.0'}',
                        padding: EdgeInsets.all(0),
                        textSize: 14,
                        textSizeValue: 14,
                        context,
                      ),
                      summaryRow(
                        'IVA:',
                        '\$${viewModel.order?.order?.totalTax ?? '0.0'}',
                        padding: EdgeInsets.all(0),
                        textSize: 14,
                        textSizeValue: 14,
                        context,
                      ),
                      summaryRow(
                        'Total :',
                        '\$${viewModel.order?.order?.totalPrice ?? '0.0'}',
                        padding: EdgeInsets.all(0),
                        isResume: true,
                        textSize: 15,
                        textSizeValue: 15,
                        context,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Divider(color: Colors.grey.shade200, height: 2),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                NavBarHeader(
                  showBackButton: true,
                  showSearch: false,
                  showShoppingCart: false,
                  searchBelow: false,
                  showImageApp: false,
                  children: Center(
                    child: Text(
                      'Orden',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: MyColors.navBarText,
                      ),
                    ),
                  ),
                ),

                if (vm.order?.order?.financialStatus != 'paid')
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 5,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: CustomButton(
                        label: 'Reintentar pago',
                        onPressed: () => vm.retryPayment(),
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

Widget summaryRow(
  String label,
  String value,
  BuildContext context, {
  Color? valueColor,
  bool isResume = false,
  double textSize = 18,
  double textSizeValue = 18,
  bool boldValue = false,
  EdgeInsets padding = const EdgeInsets.only(top: 16),
}) {
  return Padding(
    padding: padding,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isResume ? FontWeight.w500 : FontWeight.w400,
            fontSize: textSize,
            fontFamily: 'Poppins',
            color: getTextColor(context),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? getTextColor(context),
            fontSize: textSizeValue,
            fontWeight:
                isResume || boldValue ? FontWeight.w500 : FontWeight.w400,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    ),
  );
}

