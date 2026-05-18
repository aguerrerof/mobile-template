import 'package:flutter/material.dart';
import 'package:mobile_app_template/components/check_card.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:mobile_app_template/components/custom_scaffold.dart';
import 'package:mobile_app_template/components/horizontal_stepper_widget.dart';
import 'package:mobile_app_template/components/nav_bar_header.dart';
import 'package:mobile_app_template/components/notFound/empty_list_widget.dart';
import 'package:mobile_app_template/utils/card_functions.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/home/order/components/recurring_order_card.dart';
import 'package:mobile_app_template/views/home/order/list/order_list_view_model.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class OrderListScreen extends StatefulWidget {
  final bool recurring;

  const OrderListScreen({Key? key, required this.recurring});

  @override
  State<OrderListScreen> createState() => OrderListScreenState();
}

class OrderListScreenState extends State<OrderListScreen> {
  late OrderListViewModel viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    viewModel = OrderListViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("iniciando carga");
      // init();
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          (viewModel.orderList.isNotEmpty ||
              viewModel.recurringList.isNotEmpty)) {
        if (widget.recurring) {
          viewModel.fetchOrdersRecurring(false, false);
        } else {
          viewModel.fetchOrders(false);
          // viewModel.fetchOrdersRecurring(false, true);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void init() {
    viewModel.refreshOrders();
    if (widget.recurring) {
      viewModel.fetchOrdersRecurring(true, false);
    } else {
      viewModel.fetchOrders(true);
      viewModel.fetchOrdersRecurring(false, true);
    }
  }

  Future<void> _handleRefresh() async {
    init();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<OrderListViewModel>(
        builder: (context, vm, _) {
          return VisibilityDetector(
            key: const Key('order_list'),
            onVisibilityChanged: (info) {
              if (info.visibleFraction > 0.5) {
                _handleRefresh();
              }
            },
            child: CustomScaffold(
              child: Column(
                children: [
                  NavBarHeader(
                    searchBelow: false,
                    showImageApp: !widget.recurring,
                    showSearch: false,
                    showShoppingCart: true,
                    showBackButton: widget.recurring,
                    children:
                        widget.recurring
                            ? Center(
                              child: Text(
                                'Envíos programados',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: MyColors.navBarText,
                                ),
                              ),
                            )
                            : null,
                  ),
                  if (vm.isLoading)
                    const Padding(
                      padding: EdgeInsetsGeometry.only(top: 20),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.grey,
                          strokeWidth: 1.5,
                        ),
                      ),
                    ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _handleRefresh,
                      backgroundColor: MyColors.backgroundColor,
                      color: MyColors.btnColor,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        controller: _scrollController,
                        slivers: [
                          if (!widget.recurring && vm.recurringList.isNotEmpty)
                            SliverToBoxAdapter(
                              child: Row(
                                children: [
                                  Spacer(),
                                  Padding(
                                    padding: EdgeInsetsGeometry.only(
                                      top: 15,
                                      right: 20,
                                    ),
                                    child: CustomButton(
                                      label: "Gestionar Envíos programados",
                                      onPressed:
                                          () => {
                                            Navigator.of(
                                              context,
                                              rootNavigator: true,
                                            ).pushNamed(
                                              '/orderList',
                                              arguments: {'recurring': true},
                                            ),
                                          },
                                      height: 35,
                                      // type: CustomButtonType.text,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (vm.ordersInProgressList.isNotEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.only(left: 20, top: 15),
                                child: Text(
                                  'Pedidos en curso',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                    color: getTextColor(context),
                                  ),
                                  softWrap: true,
                                ),
                              ),
                            ),
                          if (vm.ordersInProgressList.isNotEmpty)
                            SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final item = vm.ordersInProgressList[index];

                                final List<dynamic> productos =
                                    item.order?.lineItems ?? [];

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8,
                                  ),
                                  child: CheckCardWidget(
                                    tapGesture: () {
                                      Navigator.of(
                                        context,
                                        rootNavigator: true,
                                      ).pushNamed(
                                        '/orderDetail',
                                        arguments: {'order': item},
                                      );
                                    },
                                    showAlwaysSubtitle: false,
                                    backgroundColor: MyColors.backgroundColor,
                                    borderColor: Colors.transparent,
                                    showCheck: false,
                                    child: Row(
                                      children: [
                                        Flexible(
                                          fit: FlexFit.loose,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    "Orden # ${item.order?.orderNumber}",
                                                    style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 18,
                                                      color: getTextColor(
                                                        context,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  if (item.extra != null &&
                                                      item.extra!.isNotEmpty)
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.red.shade100,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        "Necesita atención",
                                                        style: const TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 12,
                                                          fontFamily: 'Poppins',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsetsGeometry.symmetric(
                                                      vertical: 8,
                                                    ),
                                                child: Row(
                                                  spacing: 10,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Expanded(
                                                      // importante, para que Column use el espacio disponible
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            item.fulfillment
                                                                    ?.getStatusStep() ??
                                                                '',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Poppins',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 16,
                                                              color:
                                                                  getTextColor(
                                                                    context,
                                                                  ),
                                                            ),
                                                          ),
                                                          if ((item.fulfillment?.steps ??
                                                                      [])
                                                                  .isNotEmpty &&
                                                              (item.fulfillment?.actualStep ??
                                                                      0) >
                                                                  0)
                                                            HorizontalStepper(
                                                              totalSteps:
                                                                  item
                                                                      .fulfillment
                                                                      ?.steps
                                                                      ?.length ??
                                                                  1,
                                                              currentStep:
                                                                  item
                                                                      .fulfillment
                                                                      ?.actualStep ??
                                                                  0,
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade200,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              5,
                                                            ),
                                                      ),
                                                      height: 40,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsetsGeometry.all(
                                                              5,
                                                            ),
                                                        child: Image.asset(
                                                          'assets/images/package.png',
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                "Productos:",
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14,
                                                  color: getTextColor(context),
                                                ),
                                              ),

                                              ...productos.map((product) {
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom: 5,
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 5,
                                                            ),
                                                        child: Container(
                                                          width: 5,
                                                          height: 5,
                                                          decoration:
                                                              BoxDecoration(
                                                                color:
                                                                    getTextColor(
                                                                      context,
                                                                    ),
                                                                shape:
                                                                    BoxShape
                                                                        .circle,
                                                              ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          product.title,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Poppins',
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 12,
                                                            color: getTextColor(
                                                              context,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }),
                                            ],
                                          ),
                                        ),

                                        SizedBox(
                                          width: 15,
                                          child: Icon(
                                            Icons.arrow_forward_ios,
                                            size: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }, childCount: vm.ordersInProgressList.length),
                            ),
                          if (!vm.isLoading && vm.orderList.isNotEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.only(left: 20, top: 20),
                                child: Text(
                                  !widget.recurring
                                      ? 'Pedidos anteriores'
                                      : 'Ordenes activas',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                    color: getTextColor(context),
                                  ),
                                  softWrap: true,
                                ),
                              ),
                            ),
                          !vm.isLoading &&
                                  vm.ordersInProgressList.isEmpty &&
                                  vm.orderList.isEmpty &&
                                  (!widget.recurring ||
                                      vm.recurringList.isEmpty)
                              ? SliverFillRemaining(
                                hasScrollBody: true,
                                child: emptyView(
                                  context,
                                  'Aún no tienes pedidos para tu peludo.',
                                  '¡Aprovecha los descuentos en envíos programados para que nunca le falte lo que más le gusta.!',
                                  null,
                                  null,
                                  null,
                                  null,
                                  null,
                                ),
                              )
                              : SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final dynamic item =
                                        widget.recurring
                                            ? vm.recurringList[index]
                                            : vm.orderList[index];

                                    final List<dynamic> productos =
                                        widget.recurring
                                            ? item.lineItems
                                            : item.order?.lineItems ?? [];

                                    return widget.recurring
                                        ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                            vertical: 8,
                                          ),
                                          child: RecurringOrderCard(
                                            hasUnpaidOrder: item.hasUnpaidOrder,
                                            items: productos.length,
                                            errorMessage: null,
                                            chargeDate:
                                                item.nextChargeDate != null &&
                                                        item
                                                            .nextChargeDate
                                                            .isNotEmpty
                                                    ? formatDateOrder(
                                                      item.nextChargeDate,
                                                      null,
                                                    )
                                                    : '--',
                                            deliveryDate:
                                                item.nextDeliveryDate != null &&
                                                        item
                                                            .nextDeliveryDate
                                                            .isNotEmpty
                                                    ? formatDateOrder(
                                                      item.nextDeliveryDate,
                                                      null,
                                                    )
                                                    : '--',
                                            frequency: item.frequency,
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                '/recurringOrderDetail',
                                                arguments: {'order': item},
                                              ).then((_) {
                                                init();
                                              });
                                            },
                                          ),
                                        )
                                        : Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                            vertical: 8,
                                          ),
                                          child: CheckCardWidget(
                                            tapGesture: () {
                                              Navigator.of(
                                                context,
                                                rootNavigator: true,
                                              ).pushNamed(
                                                '/orderDetail',
                                                arguments: {'order': item},
                                              );
                                            },
                                            showAlwaysSubtitle: false,
                                            backgroundColor:
                                                MyColors.backgroundColor,
                                            borderColor: Colors.transparent,
                                            showCheck: false,
                                            child:
                                            // widget.recurring
                                            //     ?
                                            // Row(
                                            //   children: [
                                            //     Expanded(
                                            //       child: Column(
                                            //         crossAxisAlignment:
                                            //             CrossAxisAlignment.start,
                                            //         children: [
                                            //           Text(
                                            //             widget.recurring
                                            //                 ? 'Próxima entrega el ${formatDateOrder(item.nextChargeDate)}'
                                            //                 : 'Pedido el ${formatDateOrder(item.createAt)}',
                                            //             style: TextStyle(
                                            //               fontFamily: 'Poppins',
                                            //               fontWeight:
                                            //                   FontWeight.w500,
                                            //               fontSize: 18,
                                            //               color: getTextColor(
                                            //                 context,
                                            //               ),
                                            //             ),
                                            //             softWrap: true,
                                            //           ),
                                            //           Text(
                                            //             widget.recurring
                                            //                 ? item.frequency
                                            //                 : "Orden # ${item.order?.orderNumber}",
                                            //             style: TextStyle(
                                            //               fontFamily: 'Poppins',
                                            //               fontWeight:
                                            //                   FontWeight.w500,
                                            //               fontSize: 14,
                                            //               color: getTextColor(
                                            //                 context,
                                            //               ),
                                            //             ),
                                            //           ),
                                            //           const SizedBox(height: 8),
                                            //           Text(
                                            //             "Productos:",
                                            //             style: TextStyle(
                                            //               fontFamily: 'Poppins',
                                            //               fontWeight:
                                            //                   FontWeight.w400,
                                            //               fontSize: 14,
                                            //               color: getTextColor(
                                            //                 context,
                                            //               ),
                                            //             ),
                                            //           ),
                                            //           ...productos.map((product) {
                                            //             return Padding(
                                            //               padding: EdgeInsets.only(
                                            //                 bottom: 5,
                                            //               ),
                                            //               child: Row(
                                            //                 crossAxisAlignment:
                                            //                     CrossAxisAlignment
                                            //                         .center,
                                            //                 children: [
                                            //                   Padding(
                                            //                     padding:
                                            //                         EdgeInsets.symmetric(
                                            //                           horizontal: 5,
                                            //                         ),
                                            //                     child: Container(
                                            //                       width: 5,
                                            //                       height: 5,
                                            //                       decoration: BoxDecoration(
                                            //                         color:
                                            //                             getTextColor(
                                            //                               context,
                                            //                             ),
                                            //                         shape:
                                            //                             BoxShape
                                            //                                 .circle,
                                            //                       ),
                                            //                     ),
                                            //                   ),
                                            //                   Expanded(
                                            //                     child: Text(
                                            //                       product.title,
                                            //                       style: TextStyle(
                                            //                         fontFamily:
                                            //                             'Poppins',
                                            //                         fontWeight:
                                            //                             FontWeight
                                            //                                 .w400,
                                            //                         fontSize: 12,
                                            //                         color:
                                            //                             getTextColor(
                                            //                               context,
                                            //                             ),
                                            //                       ),
                                            //                     ),
                                            //                   ),
                                            //                 ],
                                            //               ),
                                            //             );
                                            //           }),
                                            //         ],
                                            //       ),
                                            //     ),
                                            //     SizedBox(
                                            //       width: 15,
                                            //       child: Icon(
                                            //         Icons.arrow_forward_ios,
                                            //         size: 15,
                                            //       ),
                                            //     ),
                                            //   ],
                                            // )
                                            // :
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "Orden # ${item.order?.orderNumber}",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Poppins',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 18,
                                                              color:
                                                                  getTextColor(
                                                                    context,
                                                                  ),
                                                            ),
                                                          ),
                                                          SizedBox(width: 10),
                                                          if (item.extra !=
                                                                  null &&
                                                              item
                                                                  .extra!
                                                                  .isNotEmpty)
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical: 4,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color:
                                                                    Colors
                                                                        .red
                                                                        .shade100,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                              ),
                                                              child: Text(
                                                                "Necesita atención",
                                                                style: const TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .red,
                                                                  fontSize: 12,
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                      Text(
                                                        'Pedido el ${formatDateOrder(item.createAt, null)}',
                                                        style: TextStyle(
                                                          fontFamily: 'Poppins',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14,
                                                          color: getTextColor(
                                                            context,
                                                          ),
                                                        ),
                                                        softWrap: true,
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        "Productos:",
                                                        style: TextStyle(
                                                          fontFamily: 'Poppins',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14,
                                                          color: getTextColor(
                                                            context,
                                                          ),
                                                        ),
                                                      ),

                                                      ...productos.map((
                                                        product,
                                                      ) {
                                                        return Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                bottom: 5,
                                                              ),
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          5,
                                                                    ),
                                                                child: Container(
                                                                  width: 5,
                                                                  height: 5,
                                                                  decoration: BoxDecoration(
                                                                    color:
                                                                        getTextColor(
                                                                          context,
                                                                        ),
                                                                    shape:
                                                                        BoxShape
                                                                            .circle,
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  product.title,
                                                                  style: TextStyle(
                                                                    fontFamily:
                                                                        'Poppins',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    fontSize:
                                                                        12,
                                                                    color:
                                                                        getTextColor(
                                                                          context,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }),
                                                    ],
                                                  ),
                                                ),

                                                SizedBox(
                                                  width: 15,
                                                  child: Icon(
                                                    Icons.arrow_forward_ios,
                                                    size: 15,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                  },
                                  childCount:
                                      widget.recurring
                                          ? vm.recurringList.length
                                          : vm.orderList.length,
                                ),
                              ),
                          const SliverToBoxAdapter(child: SizedBox(height: 40)),
                          if (vm.pageIsLoading)
                            const SliverToBoxAdapter(
                              child: SizedBox(
                                height: 40,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.grey,
                                    strokeWidth: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          const SliverToBoxAdapter(child: SizedBox(height: 40)),
                        ],
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

