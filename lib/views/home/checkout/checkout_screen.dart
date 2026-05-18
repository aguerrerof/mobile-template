import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/analitics_service.dart';
import 'package:mobile_app_template/components/check_card.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:mobile_app_template/components/custom_flushbar.dart';
import 'package:mobile_app_template/components/custom_scaffold.dart';
import 'package:mobile_app_template/components/nav_bar_header.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/home/order/detail/order_detail_screen.dart';
import 'package:mobile_app_template/views/home/checkout/checkout_view_model.dart';
import 'package:mobile_app_template/components/add_credit_card_widget.dart';
import 'package:mobile_app_template/views/home/products/product_detail_view_model.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:provider/provider.dart';
import 'package:singular_flutter_sdk/singular.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  CheckoutScreenState createState() => CheckoutScreenState();
}

class CheckoutScreenState extends State<CheckoutScreen> {
  late CheckoutViewModel viewModel;

  String _maskCardInfo(String cardInfo) {
    final value = cardInfo.trim();
    if (value.isEmpty) return value;

    final visibleChars = 4;
    final totalChars = value.replaceAll(' ', '').length;
    if (totalChars <= visibleChars) return value;

    final charsToMask = totalChars - visibleChars;
    var maskedCount = 0;
    final buffer = StringBuffer();

    for (final char in value.split('')) {
      if (char == ' ') {
        buffer.write(char);
        continue;
      }
      if (maskedCount < charsToMask) {
        buffer.write('X');
        maskedCount++;
      } else {
        buffer.write(char);
      }
    }

    return buffer.toString();
  }

  @override
  void initState() {
    super.initState();
    AnalyticsService().trackScreen('Checkout Screen');
    Singular.event("Checkout Screen");
    viewModel = CheckoutViewModel();
    viewModel.fetchUser();
    viewModel.fetchCustomerCards();
    viewModel.fetchAddresses();
    viewModel.fetchCustomersBilling();
    // viewModel.fetchFrequencies();
    viewModel.fetchTax();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.getCheckout();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<CheckoutViewModel>(
        builder: (context, vm, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (vm.doPop) {
              Navigator.pop(context);
            }
            if (vm.message.isNotEmpty) {
              showCustomFlushbar(context, message: vm.message);
              vm.updateMessage('');
            }

            if (vm.orderResult != null) {
              Navigator.pushNamed(
                context,
                '/summary',
                arguments: {'order': vm.orderResult?.data},
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
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 70,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 10,
                            children: [
                              Text(
                                vm.cardList.isEmpty
                                    ? 'Configura una tarjeta para el pago'
                                    : "Selecciona una tarjeta para el pago",
                                style: TextStyle(
                                  fontFamily: 'NeulisAlt',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              vm.cardsLoading
                                  ? Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.grey,
                                      strokeWidth: 1.5,
                                    ),
                                  )
                                  : SizedBox(
                                    height: 120,
                                    child: PageView.builder(
                                      controller: PageController(
                                        viewportFraction: 0.9,
                                      ),
                                      itemCount: vm.cardList.length + 1,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child:
                                              (index == vm.cardList.length)
                                                  ? AddDottedCardButton(
                                                    title: 'Agregar Tarjeta',
                                                    subtitle:
                                                        'Crédito o débito',
                                                    showPlus: true,
                                                    backgroundColor: MyColors
                                                        .checkColor
                                                        .withAlpha(100),
                                                    onTap: () {
                                                      AnalyticsService()
                                                          .trackEvent(
                                                            'Add card - checkout',
                                                          );
                                                      Navigator.pushNamed(
                                                        context,
                                                        '/registerCreditCard',
                                                        arguments: {
                                                          'isFromCheckout':
                                                              true,
                                                        },
                                                      ).then((_) {
                                                        vm.fetchCustomerCards();

                                                        if (vm.addressSelected ==
                                                            null) {
                                                          vm.fetchAddresses();
                                                        }
                                                        if (vm.customer ==
                                                            null) {
                                                          vm.fetchCustomersBilling();
                                                        }
                                                      });
                                                    },
                                                  )
                                                  : AddDottedCardButton(
                                                    title: _maskCardInfo(
                                                      vm
                                                          .cardList[index]
                                                          .cardInfo,
                                                    ),
                                                    // subtitle: 'Expira: --/----',
                                                    leadingLabel:
                                                        vm
                                                            .cardList[index]
                                                            .cardIssuer,
                                                    checkoutCardDesign: true,
                                                    showPlus: false,
                                                    selected:
                                                        vm
                                                            .cardList[index]
                                                            .cardInfo ==
                                                        vm
                                                            .cardSelected
                                                            ?.cardInfo,
                                                    showSelectedCheck: true,
                                                    hideTrailingWhenUnselected:
                                                        true,
                                                    dashPattern: const [0.1, 1],
                                                    withDot: false,
                                                    onTap: () {
                                                      vm.updateCard(
                                                        vm.cardList[index],
                                                      );
                                                    },
                                                  ),
                                        );
                                      },
                                      onPageChanged: (int page) {
                                        print(page);
                                        if (page < vm.cardList.length) {
                                          final card = vm.cardList[page];
                                          vm.updateCard(card);
                                        } else {
                                          vm.updateCard(null);
                                        }
                                      },
                                    ),
                                  ),

                              // ),
                              SizedBox(height: 5),
                              Divider(color: Colors.grey.shade200, height: 2),
                            ],
                          ),
                        ),
                        Text(
                          'Dirección de entrega',
                          style: TextStyle(
                            fontFamily: 'NeulisAlt',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Skeletonizer(
                          enabled: vm.addressLoading,
                          containersColor: Colors.grey.shade200,
                          effect: ShimmerEffect(
                            baseColor: Colors.grey.shade200,
                            highlightColor: Colors.grey.shade100,
                          ),
                          child: SizedBox(
                            height: vm.addressSelected == null ? 60 : 40,
                            child:
                                vm.addressSelected == null
                                    ? Padding(
                                      padding: EdgeInsets.only(top: 10),
                                      child: AddDottedCardButton(
                                        title: 'Seleccionar dirección',
                                        icon: Icon(
                                          Icons.location_on,
                                          size: 40,
                                          color: MyColors.btnColor,
                                        ),
                                        backgroundColor: Colors.transparent,
                                        showPlus: true,
                                        internalPadding: EdgeInsets.only(
                                          left: 20,
                                          right: 20,
                                          top: 5,
                                          bottom: 5,
                                        ),
                                        onTap: () {
                                          AnalyticsService().trackEvent(
                                            'Select address - checkout',
                                          );
                                          Navigator.pushNamed(
                                            context,
                                            '/listAddresses',
                                            arguments: {'isEditable': false},
                                          ).then((value) {
                                            if (value is Address) {
                                              vm.updateAddress(value);
                                            }
                                          });
                                        },
                                      ),
                                    )
                                    : GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap:
                                          () => Navigator.pushNamed(
                                            context,
                                            '/listAddresses',
                                            arguments: {'isEditable': false},
                                          ).then((value) {
                                            if (value is Address) {
                                              vm.updateAddress(value);
                                            }
                                          }),

                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: RichText(
                                              textAlign: TextAlign.left,
                                              softWrap: true,
                                              overflow: TextOverflow.visible,
                                              text: TextSpan(
                                                text:
                                                    vm.addressSelected != null
                                                        ? ''
                                                        : 'Seleccione la dirección de envío',
                                                style: TextStyle(
                                                  color: getTextColor(context),
                                                  fontFamily: 'Poppins',
                                                  fontSize: 14,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        vm
                                                            .addressSelected
                                                            ?.address1
                                                            ?.toUpperCase() ??
                                                        '',
                                                    style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize: 14,
                                                      color: getTextColor(
                                                        context,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16,
                                            color: Colors.black,
                                          ),
                                        ],
                                      ),
                                    ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Divider(
                            color: Colors.grey.shade200,
                            height: 2,
                          ),
                        ),

                        Text(
                          'Tus datos para facturación',
                          style: TextStyle(
                            fontFamily: 'NeulisAlt',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Skeletonizer(
                          enabled: vm.customerLoading,
                          containersColor: Colors.grey.shade200,
                          effect: ShimmerEffect(
                            baseColor: Colors.grey.shade200,
                            highlightColor: Colors.grey.shade100,
                          ),
                          child: SizedBox(
                            height: 60,
                            child:
                                vm.customer == null
                                    ? Padding(
                                      padding: EdgeInsets.only(top: 10),
                                      child: AddDottedCardButton(
                                        title: 'Seleccionar datos',
                                        icon: Icon(
                                          Icons.person,
                                          size: 40,
                                          color: MyColors.btnColor,
                                        ),
                                        backgroundColor: Colors.transparent,
                                        showPlus: true,
                                        internalPadding: EdgeInsets.only(
                                          left: 20,
                                          right: 20,
                                          top: 5,
                                          bottom: 5,
                                        ),
                                        onTap: () {
                                          AnalyticsService().trackEvent(
                                            'Select billing data - checkout',
                                          );
                                          Navigator.pushNamed(
                                            context,
                                            '/listCustomerBilling',
                                            arguments: {
                                              'isEditable': false,
                                              'isForCreditCard': false,
                                            },
                                          ).then((value) {
                                            if (value is CustomerBilling) {
                                              vm.updateCustomer(value);
                                            }
                                          });
                                        },
                                      ),
                                    )
                                    : GestureDetector(
                                      behavior: HitTestBehavior.opaque,

                                      onTap:
                                          () => Navigator.pushNamed(
                                            context,
                                            '/listCustomerBilling',
                                            arguments: {
                                              'isEditable': false,
                                              'isForCreditCard': false,
                                            },
                                          ).then((value) {
                                            if (value is CustomerBilling) {
                                              vm.updateCustomer(value);
                                            }
                                          }),

                                      child: Material(
                                        color: MyColors.backgroundColor,
                                        child: ListTile(
                                          tileColor: MyColors.backgroundColor,
                                          title: Text(
                                            '${vm.customer?.firstName} ${vm.customer?.lastName}'
                                                .toUpperCase(),
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: getTextColor(context),
                                            ),
                                          ),
                                          subtitle: Text(
                                            vm.customer?.identification ??
                                                'Seleccione los datos del propietario',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: getTextColor(context),
                                            ),
                                          ),
                                          trailing: Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16,
                                            color: Colors.black,
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Divider(
                            color: Colors.grey.shade200,
                            height: 2,
                          ),
                        ),

                        if (vm.showGeneralRecurrenceOptions)
                          Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 15),
                                child: RichText(
                                  textAlign: TextAlign.left,
                                  text: TextSpan(
                                    text: 'Configura tu ',
                                    style: TextStyle(
                                      color: getTextColor(context),
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Envío programado',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',

                                          color: getTextColor(context),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            ' y nunca te quedes sin comida. Ahorra hasta',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: getTextColor(context),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' 30% ',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',

                                          color: hexToColor('367C48'),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            'hoy en tu primer envío programado',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: getTextColor(context),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.only(bottom: 25),
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
                                            spacing: 5,
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
                                                  Text(
                                                    "Si, quiero envíos programados",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontFamily: 'Poppins',
                                                      color: getTextColor(
                                                        context,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: 32,
                                                ),
                                                child: RichText(
                                                  textAlign: TextAlign.left,
                                                  text: TextSpan(
                                                    text: 'Ahorrarás ',
                                                    style: TextStyle(
                                                      color: getTextColor(
                                                        context,
                                                      ),
                                                      fontFamily: 'Poppins',
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                            '\$${vm.checkout?.discount}',
                                                        style: TextStyle(
                                                          fontFamily: 'Poppins',

                                                          color: hexToColor(
                                                            '367C48',
                                                          ),
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: ' en esta orden',
                                                        style: TextStyle(
                                                          fontFamily: 'Poppins',
                                                          color: getTextColor(
                                                            context,
                                                          ),
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: 32,
                                                ),
                                                child: Text(
                                                  'Frecuencia de entrega',
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: getTextColor(
                                                      context,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: 32,
                                                ),
                                                child: SizedBox(
                                                  width: double.infinity,
                                                  child: DropdownButtonFormField(
                                                    dropdownColor:
                                                        MyColors
                                                            .backgroundColor,

                                                    initialValue:
                                                        vm.frequencies.any(
                                                              (f) =>
                                                                  f.name ==
                                                                  vm
                                                                      .frequencySelected
                                                                      ?.name,
                                                            )
                                                            ? vm.frequencySelected
                                                            : null,

                                                    items:
                                                        vm.frequencies.map((
                                                          freq,
                                                        ) {
                                                          return DropdownMenuItem<
                                                            Frequency
                                                          >(
                                                            value: freq,
                                                            child: Text(
                                                              freq.name,
                                                              style: TextStyle(
                                                                color:
                                                                    getTextColor(
                                                                      context,
                                                                    ),
                                                              ),
                                                            ),
                                                          );
                                                        }).toList(),
                                                    onChanged: (value) {
                                                      vm.setFrecuency(value);
                                                    },
                                                    decoration: InputDecoration(
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                  color:
                                                                      Colors
                                                                          .grey,
                                                                  width: 1,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                  color:
                                                                      Colors
                                                                          .grey,
                                                                  width: 1,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: 32,
                                                  top: 10,
                                                ),
                                                child: const Text(
                                                  'Podrás cambiar la frecuencia o cancelar los envíos en cualquier momento.',
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: 32,
                                                  top: 15,
                                                ),
                                                child: GridView.builder(
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 3,
                                                        mainAxisExtent: 75,
                                                        crossAxisSpacing: 10,
                                                        mainAxisSpacing: 10,
                                                      ),
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemCount:
                                                      vm
                                                          .recurrenceProducts
                                                          .length,
                                                  itemBuilder: (_, index) {
                                                    return ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                      child: Container(
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade100,
                                                        padding: EdgeInsets.all(
                                                          5,
                                                        ),
                                                        child: Image.network(
                                                          vm
                                                              .recurrenceProducts[index]
                                                              .imageUrl,
                                                          width: 50,
                                                          height: 50,
                                                          fit: BoxFit.contain,
                                                          errorBuilder:
                                                              (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) => const Icon(
                                                                Icons.error,
                                                              ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: 32,
                                                  top: 15,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Frecuencia',
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        color: getTextColor(
                                                          context,
                                                        ),
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                    Text(
                                                      'recomendada',
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        color: getTextColor(
                                                          context,
                                                        ),
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                    Text(
                                                      vm
                                                              .defaultFrecuency
                                                              ?.name ??
                                                          'Cada 4 semanas',
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        color:
                                                            MyColors.btnColor,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                    SizedBox(height: 15),
                                                    Text(
                                                      'Descuento máximo de \$30 por producto en envíos programados. Solo para productos participantes. Oferta por tiempo limitado.',
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        color: getTextColor(
                                                          context,
                                                        ),
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
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
                                  ),
                                ),
                              ),

                              SizedBox(
                                width: double.infinity,
                                child: Card(
                                  color: MyColors.cardColor,
                                  elevation: 2,
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
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          spacing: 5,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  vm.purchaseType ==
                                                          PurchaseType.unique
                                                      ? Icons
                                                          .radio_button_checked
                                                      : Icons
                                                          .radio_button_unchecked_outlined,
                                                  color:
                                                      vm.purchaseType ==
                                                              PurchaseType
                                                                  .unique
                                                          ? MyColors
                                                              .selectedBorderColor
                                                          : MyColors
                                                              .borderColor,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "No, gracias",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: 'Poppins',
                                                    color: getTextColor(
                                                      context,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            Padding(
                                              padding: EdgeInsets.only(
                                                left: 32,
                                              ),
                                              child: Text(
                                                'Comprare este(os) producto(s) solo una vez',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: getTextColor(context),
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

                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 24,
                                  bottom: 24,
                                ),
                                child: Column(
                                  spacing: 10,
                                  children: [
                                    Divider(
                                      color: Colors.grey.shade200,
                                      height: 2,
                                    ),
                                    Divider(
                                      color: Colors.grey.shade200,
                                      height: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                        // Artículos
                        Text(
                          'Tu pedido',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: vm.checkout?.items.length ?? 0,
                          itemBuilder: (context, index) {
                            final item = vm.checkout?.items[index];
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 5.0,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: Image.network(
                                            item?.imageUrl ?? '',
                                            fit: BoxFit.contain,
                                            width: 100,
                                            height: 120,
                                            loadingBuilder: (
                                              context,
                                              child,
                                              loadingProgress,
                                            ) {
                                              if (loadingProgress == null) {
                                                return child;
                                              } else {
                                                return const Center(
                                                  child:
                                                      CircularProgressIndicator(
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
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item?.title ?? '',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                  fontFamily: 'Poppins',
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                '\$${item?.price.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
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
                                                          MyColors
                                                              .backgroundColor,
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
                                                              (item?.quantity ??
                                                                          1) >
                                                                      1
                                                                  ? vm.changeQuantity(
                                                                    item!,
                                                                    -1,
                                                                    context,
                                                                  )
                                                                  : viewModel
                                                                      .remove(
                                                                        context,
                                                                        item!,
                                                                      );
                                                            },
                                                            icon: Icon(
                                                              (item?.quantity ??
                                                                          1) >
                                                                      1
                                                                  ? Icons
                                                                      .remove_circle_outline
                                                                  : Icons
                                                                      .delete_rounded,
                                                              color:
                                                                  getTextColor(
                                                                    context,
                                                                  ),
                                                            ),
                                                            height: 20,
                                                            widht: 40,
                                                            paddingHorizontal:
                                                                0,
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                          ),
                                                          Text(
                                                            '${item?.quantity}',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Poppins',
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                          (item?.quantity ??
                                                                      1) <
                                                                  (item?.stock ??
                                                                      1)
                                                              ? CustomButton(
                                                                onPressed: () {
                                                                  vm.changeQuantity(
                                                                    item!,
                                                                    1,
                                                                    context,
                                                                  );
                                                                },
                                                                icon: Icon(
                                                                  Icons
                                                                      .add_circle_outline,
                                                                  color:
                                                                      getTextColor(
                                                                        context,
                                                                      ),
                                                                ),
                                                                height: 20,
                                                                widht: 40,
                                                                paddingHorizontal:
                                                                    0,
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                              )
                                                              : SizedBox(
                                                                width: 40,
                                                              ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              if (item?.availableRecurrence ??
                                                  false)
                                                CheckCardWidget(
                                                  tapGesture: () {
                                                    vm.setPurchaseTypeProduct(
                                                      index,
                                                      PurchaseType.recurring,
                                                    );
                                                  },
                                                  paddingTop: 3,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  borderColor:
                                                      Colors.transparent,
                                                  textString:
                                                      'Envío programado',
                                                  checked:
                                                      (item?.isRecurrence ??
                                                          false),
                                                  borderColorChecked:
                                                      Colors.transparent,
                                                  padding: EdgeInsets.all(0),
                                                  titleTextStyle: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'Poppins',
                                                    color: getTextColor(
                                                      context,
                                                    ),
                                                  ),
                                                ),
                                              if (item?.availableRecurrence ??
                                                  false)
                                                CheckCardWidget(
                                                  tapGesture: () {
                                                    vm.setPurchaseTypeProduct(
                                                      index,
                                                      PurchaseType.unique,
                                                    );
                                                  },
                                                  paddingTop: 3,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  borderColor:
                                                      Colors.transparent,
                                                  textString: 'Compra única',
                                                  checked:
                                                      !(item?.isRecurrence ??
                                                          false),
                                                  borderColorChecked:
                                                      Colors.transparent,
                                                  padding: EdgeInsets.all(0),
                                                  titleTextStyle: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'Poppins',
                                                    color: getTextColor(
                                                      context,
                                                    ),
                                                  ),
                                                ),
                                              // if (item?.isRecurrence ?? false)
                                              //   Text.rich(
                                              //     TextSpan(
                                              //       children: [
                                              //         const TextSpan(
                                              //           text: 'Ahorro de  ',
                                              //           style: TextStyle(
                                              //             fontSize: 14,
                                              //             fontWeight:
                                              //                 FontWeight.w400,
                                              //             fontFamily: 'Poppins',
                                              //           ),
                                              //         ),
                                              //         TextSpan(
                                              //           text:
                                              //               '\$${(item?.appliedDiscount?.totalAmount ?? '0')}',
                                              //           style: const TextStyle(
                                              //             fontSize: 14,
                                              //             fontWeight:
                                              //                 FontWeight.w600,
                                              //             fontFamily: 'Poppins',
                                              //             color: Colors.green,
                                              //           ),
                                              //         ),
                                              //         const TextSpan(
                                              //           text:
                                              //               ' por envío recurrente',
                                              //           style: TextStyle(
                                              //             fontSize: 14,
                                              //             fontWeight:
                                              //                 FontWeight.w400,
                                              //             fontFamily: 'Poppins',
                                              //           ),
                                              //         ),
                                              //       ],
                                              //     ),
                                              //     style: const TextStyle(
                                              //       fontSize: 14,
                                              //     ),
                                              //   ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 24),
                                      child: Divider(
                                        color: Colors.grey.shade200,
                                        height: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 20),

                        // Totales
                        Text(
                          'Resumen de orden',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),

                        summaryRow(
                          'Artículos (${vm.checkout?.totalQuantity ?? ''}):',
                          '\$${vm.checkout?.subtotal ?? '0'}',
                          context,
                          textSize: 14,
                          textSizeValue: 16,
                          boldValue: true,
                        ),
                        summaryRow(
                          'Costo de envío:',
                          '\$${vm.checkout?.deliveryCost ?? '0'}',
                          context,
                          textSize: 14,
                          textSizeValue: 16,
                          boldValue: true,
                        ),
                        summaryRow(
                          'Ahorro envío programado:',
                          '-\$${vm.checkout?.discount ?? '0'}',
                          context,
                          valueColor: hexToColor('367C48'),
                          textSize: 14,
                          textSizeValue: 16,
                          boldValue: true,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Divider(
                            color: Colors.grey.shade200,
                            height: 2,
                          ),
                        ),
                        summaryRow(
                          'Subtotal:',
                          '\$${vm.checkout?.subtotalWithDiscount ?? '0'}',
                          context,
                          textSize: 14,
                          textSizeValue: 16,
                          boldValue: true,
                        ),
                        summaryRow(
                          'IVA ${vm.currentTax ?? ''}:',
                          '\$${vm.checkout?.totaTax ?? '0'}',
                          context,
                          textSize: 14,
                          textSizeValue: 16,
                          boldValue: true,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Divider(
                            color: Colors.grey.shade200,
                            height: 2,
                          ),
                        ),
                        summaryRow(
                          'Total:',
                          '\$${vm.checkout?.total ?? '0'}',
                          context,
                          isResume: true,
                          textSize: 18,
                          textSizeValue: 18,
                        ),

                        const SizedBox(height: 16),
                        CustomButton(
                          label: 'Comprar',
                          onPressed: () => vm.validate(context),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Al realizar tu pedido, aceptas nuestros Términos de Uso y Política de Privacidad. Tu envío programado seguirá activo hasta que la canceles - puedes cambiar, pausar o cancelar desde tu cuenta en cualquier momento. Aplicaremos el mejor precio disponible en cada envío.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w300,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 20),
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
                        'Finalizar compra',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: MyColors.navBarText,
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

