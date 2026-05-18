import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/analitics_service.dart';
import 'package:mobile_app_template/components/benefit_row.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:mobile_app_template/components/custom_scaffold.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/home/order/detail/order_detail_screen.dart';
import 'package:mobile_app_template/views/home/summary/summary_view_model.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:singular_flutter_sdk/singular.dart';

class SummaryScreen extends StatefulWidget {
  final ShopifyOrder order;

  const SummaryScreen({Key? key, required this.order});

  @override
  SummaryScreenState createState() => SummaryScreenState();
}

class SummaryScreenState extends State<SummaryScreen> {
  late SumaryViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = SumaryViewModel();
    viewModel.updateOrder(widget.order);
    AnalyticsService().trackScreen('Summary Screen');
    Singular.event("Summary Screen");
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<SumaryViewModel>(
        builder: (context, vm, _) {
          return CustomScaffold(
            blockBack: true,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            'Pedido confirmado',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Row(
                          children: [
                            CustomButton(
                              widht: 56,
                              onPressed: () {
                                Navigator.popUntil(
                                  context,
                                  ModalRoute.withName('/home'),
                                );
                              },
                              label: '',
                              icon: Icon(
                                Icons.close,
                                size: 24,
                                color: getTextColor(context),
                              ),
                              type: CustomButtonType.text,
                            ),
                            Spacer(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Divider(color: Colors.grey.shade200, height: 2),
                  ),

                  Text(
                    '¡Gracias por tu compra!',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 24),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SizedBox(
                      height: 179,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: Image.asset(
                          'assets/images/summary.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Orden número: ',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
                      ),
                      Text(
                        viewModel.order?.id.toString() ?? '',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: MyColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24, top: 24),
                    child: Divider(color: Colors.grey.shade200, height: 2),
                  ),
                  RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                      text:
                          'Te enviamos la confirmación y detalles de seguimiento a: ',
                      style: TextStyle(
                        color: getTextColor(context),
                        fontFamily: 'Poppins',
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: viewModel.order?.email ?? '',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 24, top: 14),
                    child: Divider(color: Colors.grey.shade200, height: 2),
                  ),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: viewModel.order?.lineItems.length ?? 0,
                    itemBuilder: (context, index) {
                      final item = viewModel.order?.lineItems[index];
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(width: 10),
                                  if (item?.image != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        item?.image ?? '',
                                        fit: BoxFit.contain,
                                        width: 73,
                                        height: 89,
                                        loadingBuilder: (
                                          context,
                                          child,
                                          loadingProgress,
                                        ) {
                                          if (loadingProgress == null) {
                                            return child;
                                          } else {
                                            return const Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.grey,
                                                strokeWidth: 1.5,
                                              ),
                                            );
                                          }
                                        },
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return const Icon(Icons.error);
                                        },
                                      ),
                                    ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      spacing: 5,
                                      children: [
                                        Text(
                                          item!.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        Text(
                                          item.variantTitle,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        Text(
                                          '\$${item.price.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.red,
                                          ),
                                        ),

                                        Text(
                                          viewModel.order?.recurrencingIds
                                                          ?.contains(
                                                            addProductVariantIdToNumber(
                                                              item.variantId ??
                                                                  '',
                                                            ),
                                                          ) !=
                                                      null &&
                                                  viewModel
                                                          .order
                                                          ?.recurrencingIds
                                                          ?.contains(
                                                            addProductVariantIdToNumber(
                                                              item.variantId ??
                                                                  '',
                                                            ),
                                                          ) ==
                                                      true
                                              ? 'Compra recurrente'
                                              : 'Compra única',
                                          style: TextStyle(
                                            color: MyColors.secondary,
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                          ),
                                        ),
                                        BenefitRow(
                                          icon: SvgPicture.asset(
                                            'assets/icons/ship_item.svg',
                                            semanticsLabel: ' ',
                                            fit: BoxFit.fill,
                                            width: 14,
                                            height: 14,
                                            colorFilter: const ColorFilter.mode(
                                              MyColors.secondary,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          text: 'Llegará en 1-3 dias hábiles',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Divider(color: Colors.grey.shade200, height: 2),
                  ),

                  Text(
                    'Será entregado en:',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    viewModel.order?.shippingAddress?.firstName ?? '',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    viewModel.order?.shippingAddress?.address1 ?? '',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Divider(color: Colors.grey.shade200, height: 2),
                  ),

                  // Totales
                  Text(
                    'Resumen de compra',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),

                  summaryRow(
                    'Artículos (${viewModel.order?.lineItems.length ?? '-'}):',
                    '\$${viewModel.order?.subtotalPrice ?? '0.0'}',
                    context,
                    textSize: 14,
                    textSizeValue: 16,
                    boldValue: true,
                  ),
                  summaryRow(
                    'Costo de envío:',
                    '\$${viewModel.order?.totalShippingPrice}',
                    context,
                    textSize: 14,
                    textSizeValue: 16,
                    boldValue: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Divider(color: Colors.grey.shade200, height: 2),
                  ),
                  summaryRow(
                    'Total antes de impuestos:',
                    '\$${viewModel.order?.subtotalPrice ?? 0.0}',
                    context,
                    textSize: 14,
                    textSizeValue: 16,
                    boldValue: true,
                  ),
                  summaryRow(
                    'Impuestos:',
                    '\$${viewModel.order?.totalTax ?? '0.0'}',
                    context,
                    textSize: 14,
                    textSizeValue: 16,
                    boldValue: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Divider(color: Colors.grey.shade200, height: 2),
                  ),
                  summaryRow(
                    'Total:',
                    '\$${viewModel.order?.totalPrice ?? '0.0'}',
                    context,
                    isResume: true,
                    textSize: 18,
                    textSizeValue: 18,
                  ),
                  SizedBox(height: 20),
                  RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                      text: 'Pagado con: ',
                      style: TextStyle(
                        color: getTextColor(context),
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                      children: [
                        TextSpan(
                          text: viewModel.order?.paymentInfo ?? '',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.blue,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  CustomButton(
                    label: 'Seguir comprando',
                    onPressed: () {
                      Navigator.popUntil(context, ModalRoute.withName('/home'));
                    },
                    type: CustomButtonType.filled,
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

