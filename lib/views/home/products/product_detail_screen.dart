import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/analitics_service.dart';
import 'package:mobile_app_template/components/alert_dialog_widget.dart';
import 'package:mobile_app_template/components/check_card.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:mobile_app_template/components/custom_expansion_title.dart';
import 'package:mobile_app_template/components/custom_scaffold.dart';
import 'package:mobile_app_template/components/nav_bar_header.dart';
import 'package:mobile_app_template/components/option_offer_widget.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/utils/card_functions.dart';
import 'package:mobile_app_template/utils/cart_helper.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/home/products/components/image_galery_section.dart';
import 'package:mobile_app_template/views/home/products/components/weight_price_card.dart';
import 'package:mobile_app_template/views/home/products/product_detail_view_model.dart';
import 'package:mobile_app_template/views/loading/loading_viewmodel.dart';
import 'package:mobile_app_template/components/page_sheet/bottom_page_sheet.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:provider/provider.dart';
import 'package:singular_flutter_sdk/singular.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ProductDetailViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = ProductDetailViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.getProduct(widget.product);
    });
    Singular.event("Product page");
    AnalyticsService().trackEvent("Product page");
  }

  @override
  Widget build(BuildContext context) {
    final loading = Provider.of<LoadingViewModel>(context);

    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<ProductDetailViewModel>(
        builder: (context, vm, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.showRecurringOptions) {
              viewModel.updateShowRecurring(false);
              CustomBottomSheet.show(
                context: context,
                title: 'Selecciona o crea un envío programado',
                initialChildSize: 0.75,
                child: ChangeNotifierProvider.value(
                  value: viewModel,
                  child: Consumer<ProductDetailViewModel>(
                    builder: (_, vm, __) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 15),
                          CheckCardWidget(
                            tapGesture: () {
                              vm.updateRecurringIdSelected(null);
                              vm.continueRecurring(context);
                            },
                            showAlwaysSubtitle: false,
                            showCheck: false,
                            textString: "Crear nuevo",
                            child: Text(
                              'Selecciona la frecuencia de envío mas adelante.',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: getTextColor(context),
                              ),
                            ),
                          ),
                          ...vm.recurringList.map((item) {
                            return CheckCardWidget(
                              tapGesture: () {
                                showPlatformAlertDialog(
                                  context: context,
                                  title: "Agregar producto",
                                  message:
                                      "¿Estás seguro de que deseas agregar el producto al envío programado ${item.id}?",
                                  confirmText: "Si, agregar",
                                  destructive: true,
                                  onConfirm: () {
                                    vm.updateRecurringIdSelected(item.id);
                                    vm.continueRecurring(context);
                                  },
                                );
                              },
                              showAlwaysSubtitle: false,
                              showCheck: false,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 5,
                                children: [
                                  Text(
                                    'Agrega a Envío programado ${item.id}',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: getTextColor(context),
                                    ),
                                  ),
                                  Text(
                                    item.frequency,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      color: getTextColor(context),
                                    ),
                                  ),

                                  RichText(
                                    textAlign: TextAlign.left,
                                    text: TextSpan(
                                      text: 'Siguiente orden ',
                                      style: TextStyle(
                                        color: getTextColor(context),
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: formatearFecha(
                                            item.nextChargeDate,
                                          ),
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            color: hexToColor('367C48'),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          // ListView.builder(
                          //   shrinkWrap: true,
                          //   physics: NeverScrollableScrollPhysics(),

                          //   itemCount: vm.recurringList.length,
                          //   itemBuilder: (context, index) {
                          //     final item = vm.recurringList[index];
                          //     return CheckCardWidget(
                          //       tapGesture: () {
                          //         showPlatformAlertDialog(
                          //           context: context,
                          //           title: "Agregar producto",
                          //           message:
                          //               "¿Estás seguro de que deseas agregar el producto al auto-envio ${index + 1}?",
                          //           confirmText: "Si, agregar",
                          //           destructive: true,
                          //           onConfirm: () {
                          //             vm.updateRecurringIdSelected(item.id);
                          //             vm.continueRecurring(context);
                          //           },
                          //         );
                          //       },
                          //       showAlwaysSubtitle: false,
                          //       showCheck: false,
                          //       child: Column(
                          //         crossAxisAlignment:
                          //             CrossAxisAlignment.start,
                          //         spacing: 5,
                          //         children: [
                          //           Text(
                          //             'Agrega a Envio auto-envio ${index + 1}',
                          //             style: TextStyle(
                          //               fontFamily: 'Poppins',
                          //               fontWeight: FontWeight.w500,
                          //               fontSize: 16,
                          //               color: getTextColor(context),
                          //             ),
                          //           ),
                          //           Text(
                          //             item.frequency,
                          //             style: TextStyle(
                          //               fontFamily: 'Poppins',
                          //               fontSize: 14,
                          //               color: getTextColor(context),
                          //             ),
                          //           ),

                          //           RichText(
                          //             textAlign: TextAlign.left,
                          //             text: TextSpan(
                          //               text: 'Siguiente orden ',
                          //               style: TextStyle(
                          //                 color: getTextColor(context),
                          //                 fontFamily: 'Poppins',
                          //                 fontSize: 12,
                          //               ),
                          //               children: [
                          //                 TextSpan(
                          //                   text: formatearFecha(
                          //                     item.nextChargeDate,
                          //                   ),
                          //                   style: TextStyle(
                          //                     fontFamily: 'Poppins',
                          //                     color: hexToColor('367C48'),
                          //                     fontWeight: FontWeight.w500,
                          //                     fontSize: 14,
                          //                   ),
                          //                 ),
                          //               ],
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          //     );
                          //   },
                          // ),
                          SizedBox(height: 20),
                        ],
                      );
                    },
                  ),
                ),
              );
            }
          });
          return CustomScaffold(
            child: Skeletonizer(
              enabled: vm.isLoading,
              containersColor: Colors.grey.shade200,
              effect: ShimmerEffect(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.grey.shade100,
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      NavBarHeader(
                        showBackButton: true,
                        showSearch: true,
                        showShoppingCart: true,
                        searchBelow: false,
                        showImageApp: false,
                      ),
                      Expanded(
                        child: CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                  top: 20,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.product.title,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: null,
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (vm.product?.vendor != null)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: 20,
                                    right: 20,
                                    top: 5,
                                  ),
                                  child: Text(
                                    "Marca: ${vm.product?.vendor}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ),
                            SliverToBoxAdapter(
                              child: const SizedBox(height: 20),
                            ),
                            SliverToBoxAdapter(
                              child: SizedBox(
                                width: double.infinity,
                                height: 250,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: ImageGalery(medias: vm.images),
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: const SizedBox(height: 10),
                            ),
                            if (vm.flavors.isNotEmpty)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Sabor: ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          viewModel.selectedFlawor ?? '',
                                          textAlign: TextAlign.start,
                                          maxLines: null,
                                          softWrap: true,
                                          overflow: TextOverflow.visible,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (vm.flavors.isNotEmpty)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsetsGeometry.only(top: 16),
                                  child: SizedBox(
                                    height: 42,
                                    child: ListView(
                                      scrollDirection: Axis.horizontal,
                                      children:
                                          vm.flavors
                                              .asMap()
                                              .entries
                                              .map(
                                                (entry) => Padding(
                                                  padding: EdgeInsets.only(
                                                    left:
                                                        entry.key == 0 ? 20 : 0,
                                                    right: 12,
                                                  ),
                                                  child: CustomButton(
                                                    label: entry.value ?? '',
                                                    onPressed:
                                                        () => vm.setFlavor(
                                                          entry.value ?? '',
                                                        ),
                                                    type:
                                                        CustomButtonType
                                                            .outline,
                                                    alwaysBackground: true,
                                                    textColor:
                                                        entry.value ==
                                                                vm.selectedFlawor
                                                            ? MyColors
                                                                .checkTextColor
                                                            : MyColors
                                                                .unckekTextColor,
                                                    boldText:
                                                        entry.value ==
                                                        vm.selectedFlawor,
                                                    backgroundColor:
                                                        entry.value ==
                                                                vm.selectedFlawor
                                                            ? MyColors
                                                                .checkColor
                                                            : MyColors
                                                                .unchekedColor,
                                                    borderRadius: 10,
                                                    borderWight:
                                                        entry.value ==
                                                                vm.selectedFlawor
                                                            ? 2.5
                                                            : 0.5,
                                                    borderColor:
                                                        entry.value ==
                                                                vm.selectedFlawor
                                                            ? MyColors
                                                                .selectedBorderColor
                                                            : MyColors
                                                                .borderColor,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                    ),
                                  ),
                                ),
                              ),
                            if ((vm.selectedSize?.getSizeValue() ?? '') != '')
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: 20,
                                    right: 20,
                                    top: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Tamaño: ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          vm.selectedSize?.getSizeValue() ?? '',
                                          textAlign: TextAlign.start,
                                          maxLines: null,
                                          softWrap: true,
                                          overflow: TextOverflow.visible,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsetsGeometry.only(top: 16),
                                child: SizedBox(
                                  height: 80, //80
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children:
                                        vm.sizes.asMap().entries.map((entry) {
                                          final variant = entry.value!;
                                          final stock = variant.getStock();
                                          final outOfStock = stock <= 0;
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              left: entry.key == 0 ? 20 : 0,
                                              right: 12.0,
                                            ),
                                            child: WeightPriceCard(
                                              price: '\$${variant.price ?? ''}',
                                              pricePerLb: '',
                                              weight:
                                                  variant.getSizeValue() ?? '',
                                              stock: stock,
                                              isOutOfStock: outOfStock,
                                              isSelected:
                                                  variant.getSizeValue() ==
                                                  vm.selectedSize
                                                      ?.getSizeValue(),
                                              onTap:
                                                  outOfStock
                                                      ? null
                                                      : () =>
                                                          vm.setSize(variant),
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 24,
                                ),
                                child: Divider(
                                  color: Colors.grey.shade200,
                                  height: 2,
                                ),
                              ),
                            ),
                            if (vm.itemSubtotalWithDiscountFirstTime != null &&
                                vm.product != null &&
                                vm.product!.isRecurring())
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: 20,
                                    right: 20,
                                    bottom: 25,
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Card(
                                      color: MyColors.cardColor,
                                      elevation: 2,
                                      shape:
                                          vm.purchaseType ==
                                                  PurchaseType.recurring
                                              ? RoundedRectangleBorder(
                                                side: BorderSide(
                                                  color:
                                                      MyColors
                                                          .selectedBorderColor,
                                                  width: 2.5,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              )
                                              : null,
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap:
                                            () => vm.setPurchaseType(
                                              PurchaseType.recurring,
                                            ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      vm.purchaseType ==
                                                              PurchaseType
                                                                  .recurring
                                                          ? Icons
                                                              .radio_button_checked
                                                          : Icons
                                                              .radio_button_unchecked_outlined,
                                                      color:
                                                          vm.purchaseType ==
                                                                  PurchaseType
                                                                      .recurring
                                                              ? MyColors
                                                                  .selectedBorderColor
                                                              : MyColors
                                                                  .borderColor,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: RichText(
                                                        textAlign:
                                                            TextAlign.left,
                                                        text: TextSpan(
                                                          text:
                                                              'Envío programado',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontFamily:
                                                                'Poppins',
                                                            color: getTextColor(
                                                              context,
                                                            ),
                                                          ),
                                                          children: [
                                                            TextSpan(
                                                              text:
                                                                  ' - envíos recurrentes',
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontFamily:
                                                                    'Poppins',
                                                                color:
                                                                    getTextColor(
                                                                      context,
                                                                    ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),

                                                    // Row(
                                                    //   crossAxisAlignment:
                                                    //       CrossAxisAlignment
                                                    //           .start,
                                                    //   children: [
                                                    //     Text(
                                                    //       "Auto envío",
                                                    //       style: TextStyle(
                                                    //         fontSize: 20,
                                                    //         fontWeight:
                                                    //             FontWeight.w600,
                                                    //         fontFamily:
                                                    //             'Poppins',
                                                    //         color: getTextColor(
                                                    //           context,
                                                    //         ),
                                                    //       ),
                                                    //     ),
                                                    //     Flexible(

                                                    //       fit: FlexFit.loose,
                                                    //       child: Text(
                                                    //         " - envíos recurrentes automáticos.",
                                                    //         style: TextStyle(
                                                    //           fontSize: 11,
                                                    //           fontWeight:
                                                    //               FontWeight
                                                    //                   .w400,
                                                    //           fontFamily:
                                                    //               'Poppins',
                                                    //           color:
                                                    //               getTextColor(
                                                    //                 context,
                                                    //               ),
                                                    //         ),
                                                    //         softWrap: true,
                                                    //       ),
                                                    //     ),
                                                    //   ],
                                                    // ),
                                                  ],
                                                ),

                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 32,
                                                  ),
                                                  child: Text(
                                                    'Ahorra ${viewModel.percentageFirstTime}% en tu primer envío programado',
                                                    style: TextStyle(
                                                      color: getTextColor(
                                                        context,
                                                      ),
                                                      fontFamily: 'Poppins',
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),

                                                  // RichText(
                                                  //   textAlign: TextAlign.left,
                                                  //   text: TextSpan(
                                                  //     text:
                                                  //         'Ahorra ${viewModel.percentageFirstTime}%',
                                                  //     style: TextStyle(
                                                  //       color: getTextColor(
                                                  //         context,
                                                  //       ),
                                                  //       //     hexToColor(
                                                  //       //   '367C48',
                                                  //       // ),
                                                  //       fontFamily: 'Poppins',
                                                  //       fontSize: 14,
                                                  //       fontWeight:
                                                  //           FontWeight.w600,
                                                  //     ),
                                                  //     children: [
                                                  //       TextSpan(
                                                  //         text:
                                                  //             ' en tu primer Auto envío',
                                                  //         style: TextStyle(
                                                  //           fontFamily:
                                                  //               'Poppins',
                                                  //           color: getTextColor(
                                                  //             context,
                                                  //           ),
                                                  //           fontSize: 14,
                                                  //           fontWeight:
                                                  //               FontWeight.w400,
                                                  //         ),
                                                  //       ),
                                                  //     ],
                                                  //   ),
                                                  // ),
                                                ),

                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 32,
                                                    top: 8,
                                                  ),
                                                  child: Row(
                                                    spacing: 10,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      vm.loadingDiscount
                                                          ? SizedBox(
                                                            height: 20,
                                                            width: 20,
                                                            child: const Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                    color:
                                                                        Colors
                                                                            .grey,
                                                                    strokeWidth:
                                                                        2,
                                                                  ),
                                                            ),
                                                          )
                                                          : Row(
                                                            children: [
                                                              Text(
                                                                "\$${vm.itemSubtotalWithDiscountFirstTime} ",
                                                                style: TextStyle(
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  color:
                                                                      getTextColor(
                                                                        context,
                                                                      ),
                                                                ),
                                                              ),
                                                              Text(
                                                                "en la primera orden",
                                                                style: TextStyle(
                                                                  fontSize: 14,
                                                                  color:
                                                                      hexToColor(
                                                                        '367C48',
                                                                      ),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontFamily:
                                                                      'Poppins',
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                      // Text(
                                                      //   "\$${vm.selectedSize?.price}",
                                                      //   style: TextStyle(
                                                      //     fontSize: 14,
                                                      //     color: getTextColor(
                                                      //       context,
                                                      //     ),
                                                      //     decoration:
                                                      //         TextDecoration
                                                      //             .lineThrough,
                                                      //     fontWeight:
                                                      //         FontWeight.w400,
                                                      //     fontFamily: 'Poppins',
                                                      //   ),
                                                      // ),
                                                    ],
                                                  ),
                                                ),

                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 10,
                                                  ),
                                                  child: Divider(
                                                    color: Colors.grey.shade200,
                                                    height: 2,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 32,
                                                  ),
                                                  child: SizedBox(
                                                    width: double.infinity,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      spacing: 5,
                                                      children: [
                                                        Row(
                                                          spacing: 10,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              width: 25,
                                                              height: 25,
                                                              decoration: BoxDecoration(
                                                                color:
                                                                    Colors
                                                                        .grey
                                                                        .shade300,
                                                                shape:
                                                                    BoxShape
                                                                        .circle,
                                                              ),
                                                              child: SizedBox(
                                                                height: 10,
                                                                width: 10,
                                                                child: Image.asset(
                                                                  'assets/images/ahorro.png',
                                                                  fit:
                                                                      BoxFit
                                                                          .contain,
                                                                ),
                                                              ),
                                                            ),

                                                            RichText(
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              text: TextSpan(
                                                                text:
                                                                    '${vm.percentageNormal}%',
                                                                style: TextStyle(
                                                                  color:
                                                                      getTextColor(
                                                                        context,
                                                                      ),
                                                                  //     hexToColor(
                                                                  //   '367C48',
                                                                  // ),
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        ' en siguientes órdenes',
                                                                    style: TextStyle(
                                                                      fontFamily:
                                                                          'Poppins',
                                                                      color: getTextColor(
                                                                        context,
                                                                      ),
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),

                                                            // Text(
                                                            //   "${vm.percentageNormal}% en siguientes órdenes",
                                                            //   style: TextStyle(
                                                            //     fontSize: 14,
                                                            //     fontWeight:
                                                            //         FontWeight
                                                            //             .w400,
                                                            //     fontFamily:
                                                            //         'Poppins',
                                                            //     color:
                                                            //         getTextColor(
                                                            //           context,
                                                            //         ),
                                                            //   ),
                                                            // ),
                                                          ],
                                                        ),
                                                        Row(
                                                          spacing: 10,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              width: 25,
                                                              height: 25,
                                                              decoration: BoxDecoration(
                                                                color:
                                                                    Colors
                                                                        .grey
                                                                        .shade300,
                                                                shape:
                                                                    BoxShape
                                                                        .circle,
                                                              ),
                                                              child: SizedBox(
                                                                height: 10,
                                                                width: 10,
                                                                child: Image.asset(
                                                                  'assets/images/tiempo.png',
                                                                  fit:
                                                                      BoxFit
                                                                          .contain,
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                              "Nunca te quedes sin comida.",
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontFamily:
                                                                    'Poppins',
                                                                color:
                                                                    getTextColor(
                                                                      context,
                                                                    ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          spacing: 10,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              width: 25,
                                                              height: 25,
                                                              decoration: BoxDecoration(
                                                                color:
                                                                    Colors
                                                                        .grey
                                                                        .shade300,
                                                                shape:
                                                                    BoxShape
                                                                        .circle,
                                                              ),
                                                              child: SizedBox(
                                                                height: 10,
                                                                width: 10,
                                                                child: Image.asset(
                                                                  'assets/images/calendario.png',
                                                                  fit:
                                                                      BoxFit
                                                                          .contain,
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                "Cambia o cancela cuando quieras.",
                                                                style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  color:
                                                                      getTextColor(
                                                                        context,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.only(left: 20, right: 20),
                                child: Card(
                                  elevation: 2,
                                  color: MyColors.cardColor,
                                  shape:
                                      vm.purchaseType == PurchaseType.unique
                                          ? RoundedRectangleBorder(
                                            side: BorderSide(
                                              color:
                                                  MyColors.selectedBorderColor,
                                              width: 2.5,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          )
                                          : null,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap:
                                        () => vm.setPurchaseType(
                                          PurchaseType.unique,
                                        ),
                                    child: ListTile(
                                      title: Text(
                                        "Comprar una vez",
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: getTextColor(context),
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding: EdgeInsetsGeometry.only(
                                          top: 5,
                                        ),
                                        child: Text(
                                          "\$${vm.selectedSize?.price}",
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w700,
                                            color: getTextColor(context),
                                          ),
                                        ),
                                      ),
                                      leading: Icon(
                                        vm.purchaseType == PurchaseType.unique
                                            ? Icons.radio_button_checked
                                            : Icons
                                                .radio_button_unchecked_outlined,
                                        color:
                                            vm.purchaseType ==
                                                    PurchaseType.unique
                                                ? MyColors.selectedBorderColor
                                                : MyColors.borderColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                  top: 25,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 10,
                                  children: [
                                    const Text(
                                      "Cantidad",
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    vm.avaliableCount.isNotEmpty
                                        ? Row(
                                          children: [
                                            Material(
                                              color: Colors.transparent,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                    ),
                                                width: 100,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: MyColors.borderColor,
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: DropdownButtonHideUnderline(
                                                  child: DropdownButton<int>(
                                                    dropdownColor:
                                                        MyColors
                                                            .backgroundColor,
                                                    value: vm.count,
                                                    icon: const Icon(
                                                      Icons.keyboard_arrow_down,
                                                    ),
                                                    items:
                                                        vm.avaliableCount.map((
                                                          v,
                                                        ) {
                                                          return DropdownMenuItem(
                                                            value: v,
                                                            child: Text(
                                                              "$v",
                                                              style: TextStyle(
                                                                color:
                                                                    getTextColor(
                                                                      context,
                                                                    ),
                                                              ),
                                                            ),
                                                          );
                                                        }).toList(),
                                                    onChanged:
                                                        (v) =>
                                                            vm.setCount(v ?? 1),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 20),
                                            OptionOfferWidget(
                                              icon:
                                                  'assets/icons/ship_item.svg',
                                              title: 'Envío: 1-3 días',
                                              colorFilter: Colors.grey.shade600,
                                            ),
                                          ],
                                        )
                                        : const Text(
                                          "PRODUCTO AGOTADO",
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.red,
                                          ),
                                        ),
                                  ],
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 25,
                                ),
                                child: Divider(
                                  color: Colors.grey.shade200,
                                  height: 2,
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  "Información del producto",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Theme(
                                      data: Theme.of(context).copyWith(
                                        dividerColor: Colors.transparent,
                                      ),
                                      child: CustomExpansionTile(
                                        title: Text(
                                          "Detalles",
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: getTextColor(context),
                                          ),
                                        ),
                                        expanded: true,
                                        childrenPadding: EdgeInsets.only(
                                          left: 20,
                                          right: 20,
                                          bottom: 20,
                                        ),
                                        children: Text(
                                          widget.product.description ?? '',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                            color: getTextColor(context),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      color: Colors.grey.shade200,
                                      height: 2,
                                    ),

                                    SizedBox(height: 60),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // ),
                  ),
                  if (vm.avaliableCount.isNotEmpty)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: MyColors.backgroundColor,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: 5,
                            top: 5,
                          ),

                          child: CustomButton(
                            label:
                                vm.purchaseType == PurchaseType.recurring
                                    ? 'Configurar envío programado'
                                    : 'Agregar al carrito',
                            borderRadius: 23,
                            onPressed:
                                () =>
                                    vm.purchaseType == PurchaseType.recurring
                                        ? viewModel.addProduct(context, loading)
                                        : addToCart(
                                          context: context,
                                          loading: loading,
                                          product: vm.product!,
                                          count: vm.count,
                                          goToConfirmCart: true,
                                          showBottomDetail: false,
                                          showPopup: false,
                                          isRecurrence:
                                              vm.purchaseType ==
                                              PurchaseType.recurring,
                                          applyDiscount:
                                              vm.purchaseType ==
                                              PurchaseType.recurring,
                                        ),
                            type: CustomButtonType.filled,
                          ),
                        ),
                      ),
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

