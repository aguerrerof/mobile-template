import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/analitics_service.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:mobile_app_template/components/custom_scaffold.dart';
import 'package:mobile_app_template/components/nav_bar_header.dart';
import 'package:mobile_app_template/components/notFound/empty_list_widget.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/home/order/detail/order_detail_screen.dart';
import 'package:mobile_app_template/views/home/payments/list/credit_card_list_view_model.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:provider/provider.dart';

class CreditCardListScreen extends StatefulWidget {
  final bool isSelectionEnable;
  const CreditCardListScreen({Key? key, required this.isSelectionEnable});

  @override
  CreditCardListScreenState createState() => CreditCardListScreenState();
}

class CreditCardListScreenState extends State<CreditCardListScreen> {
  late CreditCardListViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = CreditCardListViewModel();
    viewModel.fetchUserCards();
  }

  Future<void> _handleRefresh() async {
    viewModel.fetchUserCards();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<CreditCardListViewModel>(
        builder: (context, vm, _) {
          return CustomScaffold(
            // cupertinoNavigationBar: CupertinoNavigationBar(
            //   backgroundColor: Colors.transparent,
            //   leading: CupertinoButton(
            //     padding: EdgeInsets.zero,
            //     child: const Icon(CupertinoIcons.back),
            //     onPressed: () => Navigator.pop(context),
            //   ),
            //   middle: Text(
            //     'Tarjetas',
            //     style: TextStyle(
            //       fontFamily: 'Poppins',
            //       fontSize: 16,
            //       fontWeight: FontWeight.w500,
            //     ),
            //   ),
            // ),
            // materialNavigationBar: AppBar(
            //   leading: BackButton(onPressed: () => Navigator.pop(context)),
            //   title: Text(
            //     'Tarjetas',
            //     style: TextStyle(
            //       fontFamily: 'Poppins',
            //       fontSize: 16,
            //       fontWeight: FontWeight.w500,
            //     ),
            //   ),
            //   actions: [],
            // ),
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
                      'Tarjetas vinculadas',
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
                      padding: EdgeInsetsGeometry.only(top: 30),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.grey,
                          strokeWidth: 1.5,
                        ),
                      ),
                    )
                    : viewModel.cards.isEmpty
                    ? emptyView(
                      context,
                      'No tienes tarjetas vinculadas',
                      'Vincula una tarjeta de crédito o débito para realizar pagos más rápido.',
                      null,
                      "Vincular tarjeta",
                      () {
                        AnalyticsService().trackEvent('Add card - List');
                        Navigator.pushNamed(
                          context,
                          '/registerCreditCard',
                          arguments: {'isFromCheckout': false},
                        ).then((_) {
                          viewModel.fetchUserCards();
                        });
                      },
                      null,
                      null,
                    )
                    : Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: RefreshIndicator(
                              onRefresh: _handleRefresh,
                              backgroundColor: MyColors.backgroundColor,
                              color: MyColors.btnColor,
                              child: CustomScrollView(
                                slivers: [
                                  SliverToBoxAdapter(
                                    child: SizedBox(height: 24),
                                  ),
                                  if (widget.isSelectionEnable)
                                    SliverToBoxAdapter(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          left: 20,
                                          right: 20,
                                          bottom: 20,
                                        ),
                                        child: Text(
                                          'Seleccione la tarjeta.',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  SliverList(
                                    delegate: SliverChildBuilderDelegate((
                                      context,
                                      index,
                                    ) {
                                      final card = viewModel.cards[index];

                                      return GestureDetector(
                                        onTap: () {
                                          if (widget.isSelectionEnable) {
                                            Navigator.pop(context, card);
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
                                                Text(
                                                  card.cardInfo,
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: getTextColor(
                                                      context,
                                                    ),
                                                  ),
                                                ),

                                                Text(
                                                  card.cardIssuer,
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 12,
                                                    color: getTextColor(
                                                      context,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  card.clientName,
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 12,
                                                    color: getTextColor(
                                                      context,
                                                    ),
                                                  ),
                                                ),
                                                summaryRow(
                                                  '${card.isExpired ? 'Vencida' : 'Activa'} ',
                                                  '',
                                                  padding: EdgeInsets.all(0),
                                                  textSize: 12,
                                                  context,
                                                ),

                                                if (!widget.isSelectionEnable)
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      top: 10,
                                                    ),
                                                    child: Row(
                                                      spacing: 5,
                                                      children: [
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
                                                                        "Eliminar tarjeta",
                                                                      ),
                                                                      content:
                                                                          const Text(
                                                                            "¿Estás seguro de que deseas eliminar la tarjeta?",
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
                                                                            viewModel.deleteCard(
                                                                              context,
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
                                                                          MyColors
                                                                              .backgroundColor,
                                                                      title: Text(
                                                                        "Eliminar tarjeta",
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
                                                                        "¿Estás seguro de que deseas eliminar la tarjeta?",
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
                                                                            viewModel.deleteCard(
                                                                              context,
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
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }, childCount: viewModel.cards.length),
                                  ),
                                  SliverToBoxAdapter(
                                    child: SizedBox(height: 70),
                                  ),
                                ],
                              ),
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
                                      'Add card - List',
                                    );
                                    Navigator.pushNamed(
                                      context,
                                      '/registerCreditCard',
                                      arguments: {'isFromCheckout': false},
                                    ).then((_) {
                                      viewModel.fetchUserCards();
                                    });
                                  },

                                  label: 'Vincular tarjeta',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                // Expanded(
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     spacing: 10,
                //     children: [
                //       SizedBox(height: 24),
                //       if (widget.isSelectionEnable)
                //         Padding(
                //           padding: EdgeInsets.only(
                //             left: 20,
                //             right: 20,
                //             bottom: 10,
                //           ),
                //           child: Text(
                //             'Seleccione la tarjeta.',
                //             style: TextStyle(
                //               fontFamily: 'Poppins',
                //               fontSize: 18,
                //             ),
                //           ),
                //         ),
                //       // Expanded(
                //       //   child:
                //       ListView.builder(
                //         itemCount: viewModel.cards.length,
                //         itemBuilder: (context, index) {
                //           final card = viewModel.cards[index];
                //           return GestureDetector(
                //             onTap: () {
                //               if (widget.isSelectionEnable) {
                //                 Navigator.pop(context, card);
                //               }
                //             },
                //             child: Card(
                //               color: MyColors.backgroundColor,
                //               margin: EdgeInsets.only(
                //                 top: 10,
                //                 left: 20,
                //                 right: 20,
                //                 bottom: 5,
                //               ),
                //               child: Padding(
                //                 padding: EdgeInsets.all(10),
                //                 child: Column(
                //                   crossAxisAlignment:
                //                       CrossAxisAlignment.start,
                //                   children: [
                //                     Text(
                //                       card.cardInfo,
                //                       style: TextStyle(
                //                         fontFamily: 'Poppins',
                //                         fontSize: 16,
                //                         fontWeight: FontWeight.w500,
                //                         color: getTextColor(context),
                //                       ),
                //                     ),

                //                     Text(
                //                       card.cardIssuer,
                //                       style: TextStyle(
                //                         fontFamily: 'Poppins',
                //                         fontSize: 12,
                //                         color: getTextColor(context),
                //                       ),
                //                     ),
                //                     Text(
                //                       card.clientName,
                //                       style: TextStyle(
                //                         fontFamily: 'Poppins',
                //                         fontSize: 12,
                //                         color: getTextColor(context),
                //                       ),
                //                     ),
                //                     summaryRow(
                //                       '${card.isExpired ? 'Vencida' : 'Activa'} ',
                //                       '',
                //                       padding: EdgeInsets.all(0),
                //                       textSize: 12,
                //                       context,
                //                     ),

                //                     if (!widget.isSelectionEnable)
                //                       Padding(
                //                         padding: EdgeInsets.only(top: 10),
                //                         child: Row(
                //                           spacing: 5,
                //                           children: [
                //                             CustomButton(
                //                               height: 30,
                //                               type:
                //                                   CustomButtonType.outline,
                //                               onPressed: () {
                //                                 if (Platform.isIOS) {
                //                                   showCupertinoDialog(
                //                                     context: context,
                //                                     builder:
                //                                         (
                //                                           ctx,
                //                                         ) => CupertinoAlertDialog(
                //                                           title: const Text(
                //                                             "Eliminar tarjeta",
                //                                           ),
                //                                           content: const Text(
                //                                             "¿Estás seguro de que deseas eliminar la tarjeta?",
                //                                           ),
                //                                           actions: [
                //                                             CupertinoDialogAction(
                //                                               child: const Text(
                //                                                 "Cancelar",
                //                                               ),
                //                                               onPressed:
                //                                                   () =>
                //                                                       Navigator.pop(
                //                                                         ctx,
                //                                                       ),
                //                                             ),
                //                                             CupertinoDialogAction(
                //                                               isDestructiveAction:
                //                                                   true,
                //                                               onPressed: () {
                //                                                 Navigator.pop(
                //                                                   ctx,
                //                                                 );
                //                                                 viewModel
                //                                                     .deleteCard(
                //                                                       context,
                //                                                       index,
                //                                                     );
                //                                               },
                //                                               child: const Text(
                //                                                 "Eliminar",
                //                                               ),
                //                                             ),
                //                                           ],
                //                                         ),
                //                                   );
                //                                 } else {
                //                                   showDialog(
                //                                     context: context,
                //                                     builder:
                //                                         (
                //                                           ctx,
                //                                         ) => AlertDialog(
                //                                           backgroundColor:
                //                                               MyColors
                //                                                   .backgroundColor,
                //                                           title: const Text(
                //                                             "Eliminar tarjeta",
                //                                           ),
                //                                           content: const Text(
                //                                             "¿Estás seguro de que deseas eliminar la tarjeta?",
                //                                           ),
                //                                           actions: [
                //                                             TextButton(
                //                                               onPressed:
                //                                                   () =>
                //                                                       Navigator.pop(
                //                                                         ctx,
                //                                                       ),
                //                                               child: const Text(
                //                                                 "Cancelar",
                //                                               ),
                //                                             ),
                //                                             TextButton(
                //                                               onPressed: () {
                //                                                 Navigator.pop(
                //                                                   ctx,
                //                                                 );
                //                                                 viewModel
                //                                                     .deleteCard(
                //                                                       context,
                //                                                       index,
                //                                                     );
                //                                               },
                //                                               child: const Text(
                //                                                 "Eliminar",
                //                                               ),
                //                                             ),
                //                                           ],
                //                                         ),
                //                                   );
                //                                 }
                //                               },
                //                               label: 'Eliminar',
                //                             ),
                //                           ],
                //                         ),
                //                       ),
                //                   ],
                //                 ),
                //               ),
                //             ),
                //           );
                //         },
                //       ),
                //       // ),
                //       Padding(
                //         padding: EdgeInsets.symmetric(horizontal: 20),
                //         child: CustomButton(
                //           onPressed:
                //               () => {
                //                 Navigator.pushNamed(
                //                   context,
                //                   '/registerCreditCard',
                //                   arguments: {'isFromCheckout': false},
                //                 ).then((_) {
                //                   viewModel.fetchUserCards();
                //                 }),
                //               },

                //           label: 'Vincular tarjeta',
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          );
        },
      ),
    );
  }
}

