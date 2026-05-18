import 'package:mobile_app_template/components/page_sheet/bottom_page_sheet.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/analitics_service.dart';
import 'package:mobile_app_template/components/check_card.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:mobile_app_template/components/custom_scaffold.dart';
import 'package:mobile_app_template/components/nav_bar_header.dart';
import 'package:mobile_app_template/components/notFound/empty_list_widget.dart';
import 'package:mobile_app_template/utils/session_helper.dart';
import 'package:mobile_app_template/views/home/shopingCart/shoping_cart_view_model.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ShoppingCartScreen extends StatefulWidget {
  @override
  ShoppingCartScreenState createState() => ShoppingCartScreenState();
}

class ShoppingCartScreenState extends State<ShoppingCartScreen> {
  late ShopingCartViewModel viewModel;

  @override
  void initState() {
    super.initState();
    AnalyticsService().trackScreen('Shopping Cart Screen');
    viewModel = ShopingCartViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.getOrders();
      viewModel.getCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<ShopingCartViewModel>(
        builder: (context, vm, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // context.read<CartProvider>().setCount(vm.products.length);

            if (vm.showDeletedItems) {
              vm.updateShowDeletedItems(false);
              CustomBottomSheet.show(
                context: context,
                title:
                    'Estos productos han sido eliminado de tu carrito de compras por falta de stock',
                initialChildSize: 0.75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 15),
                    ...vm.deletedItemslist.map((item) {
                      return SizedBox(
                        height: 100,
                        child: Material(
                          color: Colors.transparent,
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item.imageUrl,
                                      width: 70,
                                      fit: BoxFit.contain,
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          item.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            fontFamily: 'NeulisAlt',
                                            color: getTextColor(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    SizedBox(height: 20),
                  ],
                ),
              );
            }
          });

          return CustomScaffold(
            child: Column(
              children: [
                NavBarHeader(
                  showBackButton: true,
                  showSearch: false,
                  showImageApp: false,
                  showShoppingCart: false,
                  searchBelow: false,
                  children: Center(
                    child: Text(
                      'Carrito',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: MyColors.navBarText,
                      ),
                    ),
                  ),
                ),
                vm.isLoading
                    ? const Padding(
                      padding: EdgeInsetsGeometry.only(top: 20),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.grey,
                          strokeWidth: 1.5,
                        ),
                      ),
                    )
                    : vm.products.isEmpty
                    ? Expanded(
                      child: emptyView(
                        context,
                        'Tu carrito esta vacío por ahora',
                        'Encuentra comidas, snacks y accesorios que le van a encantar a tu mascota.',
                        Image.asset('assets/images/notFound.png', height: 234),

                        // SizedBox(
                        //   width: 140,
                        //   child: Image.asset(
                        //     'assets/images/app_name.png',
                        //     fit: BoxFit.cover,
                        //     colorBlendMode: BlendMode.srcIn,
                        //     color: MyColors.btnColor,
                        //   ),
                        // ),
                        "Explorar productos",
                        () {
                          Session.pendingHomeTabIndex = 0;
                          Navigator.popUntil(
                            context,
                            ModalRoute.withName('/home'),
                          );
                        },
                        viewModel.haveOrders ? "Ver pedidos anteriores" : null,
                        () {
                          Session.pendingHomeTabIndex = 2;
                          Navigator.popUntil(
                            context,
                            ModalRoute.withName('/home'),
                          );
                        },
                      ),
                    )
                    : Expanded(
                      child: Stack(
                        children: [
                          viewModel.isLoading
                              ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.grey,
                                  strokeWidth: 1.5,
                                ),
                              )
                              : SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Skeletonizer(
                                      enabled: viewModel.isSubtotalLoading,
                                      containersColor: Colors.grey.shade200,
                                      effect: ShimmerEffect(
                                        baseColor: Colors.grey.shade200,
                                        highlightColor: Colors.grey.shade100,
                                      ),
                                      child:
                                          !viewModel.isSubtotalLoading &&
                                                  vm.subtotal == null
                                              ? SizedBox.shrink()
                                              : Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(height: 20),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Subtotal productos:',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontFamily:
                                                                'Poppins',
                                                            color: getTextColor(
                                                              context,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          '\$${viewModel.total.toStringAsFixed(2)}',
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    'Poppins',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                      child: LinearProgressIndicator(
                                                        value: vm.progress,
                                                        backgroundColor:
                                                            Colors
                                                                .blue
                                                                .shade100,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                              Color
                                                            >(
                                                              MyColors.btnColor,
                                                            ),
                                                        minHeight: 8,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),

                                                    Row(
                                                      spacing: 10,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        if (!viewModel
                                                            .isSubtotalLoading)
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsGeometry.only(
                                                                  top: 5,
                                                                ),
                                                            child: SvgPicture.asset(
                                                              'assets/icons/offer.svg',
                                                              semanticsLabel:
                                                                  ' ',
                                                              width: 18,
                                                              height: 18,
                                                              colorFilter:
                                                                  ColorFilter.mode(
                                                                    Colors.red,
                                                                    BlendMode
                                                                        .srcIn,
                                                                  ),
                                                            ),
                                                          ),
                                                        Expanded(
                                                          child: Text(
                                                            'Tus compras superiores a \$${vm.subtotal?.minAmountFreeDelivery?.toStringAsFixed(2)} tienen envío gratis',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Poppins',
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 24,
                                        bottom: 24,
                                        left: 20,
                                        right: 20,
                                      ),
                                      child: Divider(
                                        color: Colors.grey.shade200,
                                        height: 2,
                                      ),
                                    ),

                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        bottom: 18,
                                      ),
                                      child: Text(
                                        'Tus artículos',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),

                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),

                                      itemCount: viewModel.products.length,
                                      itemBuilder: (context, index) {
                                        final item = viewModel.products[index];
                                        return Container(
                                          margin: EdgeInsets.symmetric(
                                            // vertical: 8,
                                            horizontal: 12,
                                          ),
                                          color: Colors.transparent,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 20.0,
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            15,
                                                          ),
                                                      child: Image.network(
                                                        item.imageUrl,
                                                        fit: BoxFit.contain,
                                                        width: 110,
                                                        height: 130,
                                                        loadingBuilder: (
                                                          context,
                                                          child,
                                                          loadingProgress,
                                                        ) {
                                                          if (loadingProgress ==
                                                              null) {
                                                            return child;
                                                          } else {
                                                            return const Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                    color:
                                                                        Colors
                                                                            .grey,
                                                                    strokeWidth:
                                                                        1.5,
                                                                  ),
                                                            );
                                                          }
                                                        },
                                                        errorBuilder: (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return const Icon(
                                                            Icons.error,
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        spacing: 3,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            item.title,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'NeulisAlt',
                                                            ),
                                                          ),

                                                          if (item.flavor != '')
                                                            Text(
                                                              '${item.flavor}',
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Poppins',
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          if (item.size != '')
                                                            Text(
                                                              '${item.size}',
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Poppins',
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          Text(
                                                            '\$${item.price.toStringAsFixed(2)}',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Poppins',
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                          SizedBox(height: 10),
                                                          Row(
                                                            children: [
                                                              Spacer(),
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                        Radius.circular(
                                                                          12.5,
                                                                        ),
                                                                      ),
                                                                  border: Border.all(
                                                                    color:
                                                                        getTextColor(
                                                                          context,
                                                                        )!,
                                                                  ),
                                                                ),

                                                                child: SizedBox(
                                                                  height: 25,
                                                                  width: 120,
                                                                  child: Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      CustomButton(
                                                                        onPressed: () {
                                                                          item.quantity >
                                                                                  1
                                                                              ? viewModel.changeQuantity(
                                                                                index,
                                                                                -1,
                                                                              )
                                                                              : viewModel.remove(
                                                                                context,
                                                                                index,
                                                                              );
                                                                        },
                                                                        icon: Icon(
                                                                          item.quantity >
                                                                                  1
                                                                              ? Icons.remove_circle_outline
                                                                              : Icons.delete_rounded,
                                                                          color: getTextColor(
                                                                            context,
                                                                          ),
                                                                        ),
                                                                        height:
                                                                            20,
                                                                        widht:
                                                                            40,
                                                                        paddingHorizontal:
                                                                            0,
                                                                        backgroundColor:
                                                                            Colors.transparent,
                                                                      ),
                                                                      Text(
                                                                        '${item.quantity}',
                                                                        style: TextStyle(
                                                                          fontFamily:
                                                                              'Poppins',
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                      item.quantity <
                                                                              item.stock
                                                                          ? CustomButton(
                                                                            onPressed: () {
                                                                              viewModel.changeQuantity(
                                                                                index,
                                                                                1,
                                                                              );
                                                                            },
                                                                            icon: Icon(
                                                                              Icons.add_circle_outline,
                                                                              color: getTextColor(
                                                                                context,
                                                                              ),
                                                                            ),
                                                                            height:
                                                                                20,
                                                                            widht:
                                                                                40,
                                                                            paddingHorizontal:
                                                                                0,
                                                                            backgroundColor:
                                                                                Colors.transparent,
                                                                          )
                                                                          : SizedBox(
                                                                            width:
                                                                                40,
                                                                          ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          if (item
                                                              .availableRecurrence)
                                                            CheckCardWidget(
                                                              tapGesture:
                                                                  () => viewModel
                                                                      .updateRecurrence(
                                                                        index,
                                                                        !(item.isRecurrence ??
                                                                            false),
                                                                      ),
                                                              paddingTop: 3,
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                              borderColor:
                                                                  Colors
                                                                      .transparent,
                                                              textString:
                                                                  'Envío programado',
                                                              checked:
                                                                  item.isRecurrence ??
                                                                  false,
                                                              hideChildWhenUnchecked:
                                                                  true,
                                                              borderColorChecked:
                                                                  Colors
                                                                      .transparent,
                                                              padding:
                                                                  EdgeInsets.all(
                                                                    0,
                                                                  ),
                                                              titleTextStyle: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontFamily:
                                                                    'Poppins',
                                                                color:
                                                                    getTextColor(
                                                                      context,
                                                                    ),
                                                              ),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  const SizedBox(
                                                                    height: 10,
                                                                  ),

                                                                  const Text(
                                                                    'Puedes cambiar la frecuencia o cancelar en cualquier momento desde tu cuenta.',
                                                                    style: TextStyle(
                                                                      fontFamily:
                                                                          'Poppins',
                                                                      fontSize:
                                                                          12,
                                                                      color:
                                                                          Colors
                                                                              .grey,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          if (item
                                                              .availableRecurrence)
                                                            CheckCardWidget(
                                                              tapGesture:
                                                                  () => viewModel
                                                                      .updateRecurrence(
                                                                        index,
                                                                        !(item.isRecurrence ??
                                                                            false),
                                                                      ),
                                                              paddingTop: 3,
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                              borderColor:
                                                                  Colors
                                                                      .transparent,
                                                              textString:
                                                                  'Envío único',
                                                              checked:
                                                                  !(item.isRecurrence ??
                                                                      false),
                                                              borderColorChecked:
                                                                  Colors
                                                                      .transparent,
                                                              padding:
                                                                  EdgeInsets.all(
                                                                    0,
                                                                  ),
                                                              titleTextStyle: TextStyle(
                                                                fontSize: 15,
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
                                                  ],
                                                ),

                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 16,
                                                      ),
                                                  child: Divider(
                                                    color: Colors.grey.shade200,
                                                    height: 2,
                                                  ),
                                                ),
                                                if (index ==
                                                    viewModel.products.length -
                                                        1)
                                                  SizedBox(height: 50),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    // ),
                                  ],
                                ),
                              ),
                          if (viewModel.products.isNotEmpty)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                color: MyColors.backgroundColor,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 20.0,
                                    right: 20,
                                    top: 5,
                                    bottom: 5,
                                  ),
                                  child: CustomButton(
                                    label: 'Ir a pagar',
                                    onPressed:
                                        () => {viewModel.goToCheckout(context)},
                                    borderRadius: 24,
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

