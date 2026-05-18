import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:mobile_app_template/components/custom_scaffold.dart';
import 'package:mobile_app_template/components/nav_bar_header.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/home/shopingCart/Confirmation/confirmation_add_shoping_cart_view_model.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ConfirmationAddShoppingCartScreen extends StatefulWidget {
  final Product product;
  final bool? isRecurrence;

  const ConfirmationAddShoppingCartScreen({
    Key? key,
    required this.product,
    this.isRecurrence,
  });

  @override
  ConfirmationAddShoppingCartScreenState createState() =>
      ConfirmationAddShoppingCartScreenState();
}

class ConfirmationAddShoppingCartScreenState
    extends State<ConfirmationAddShoppingCartScreen> {
  late ConfirmationShopingCartViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = ConfirmationShopingCartViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.getCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<ConfirmationShopingCartViewModel>(
        builder: (context, vm, _) {
          // WidgetsBinding.instance.addPostFrameCallback((_) {
          //   if (vm.products.isNotEmpty) {
          //     context.read<CartProvider>().setCount(vm.products.length);
          //   }
          // });

          return CustomScaffold(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NavBarHeader(
                    showBackButton: true,
                    showSearch: true,
                    showShoppingCart: true,
                    searchBelow: false,
                    showImageApp: false,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        Row(
                          spacing: 10,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.check_mark,
                              size: 16,
                              fontWeight: FontWeight.w700,
                              color: hexToColor('367C48'),
                            ),
                            Text(
                              "Agregado al carrito",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                color: hexToColor('367C48'),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      widget.product.getOnlyImages().first,
                                      fit: BoxFit.contain,
                                      width: 90,
                                      height: 100,
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
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      // spacing: 5,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.product.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        Row(
                                          spacing: 10,
                                          children: [
                                            if (widget.product
                                                    .getSelectedVariant()
                                                    ?.getFlavorValue() !=
                                                null)
                                              Text(
                                                '${widget.product.getSelectedVariant()?.getFlavorValue()}',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 14,
                                                ),
                                              ),
                                            if (widget.product
                                                    .getSelectedVariant()
                                                    ?.getSizeValue() !=
                                                null)
                                              Text(
                                                '${widget.product.getSelectedVariant()?.getSizeValue()}',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 14,
                                                ),
                                              ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        if (widget.isRecurrence == true)
                                          Row(
                                            spacing: 10,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding:
                                                    EdgeInsetsGeometry.only(
                                                      top: 5,
                                                    ),
                                                child: SvgPicture.asset(
                                                  'assets/icons/repeat.svg',
                                                  semanticsLabel: ' ',
                                                  width: 25,
                                                  height: 25,
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.black,
                                                    BlendMode.srcIn,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  "Configura la frecuencia de envío en el checkout",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: 'Poppins',
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (viewModel.subtotal?.initialRecurrencePercentage !=
                                null &&
                            widget.isRecurrence == true)
                          Row(
                            spacing: 10,
                            // mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsetsGeometry.only(top: 5),
                                child: SvgPicture.asset(
                                  'assets/icons/offer.svg',
                                  semanticsLabel: ' ',
                                  width: 18,
                                  height: 18,
                                  colorFilter: ColorFilter.mode(
                                    hexToColor('367C48')!,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),

                              Expanded(
                                child: RichText(
                                  textAlign: TextAlign.left,
                                  text: TextSpan(
                                    text: 'Ahorra ',
                                    style: TextStyle(
                                      color: getTextColor(context),
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            '${viewModel.subtotal?.initialRecurrencePercentage ?? ''}%',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: hexToColor('367C48'),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' en tu primer envío programado.',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: getTextColor(context),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                        Padding(
                          padding: const EdgeInsets.only(top: 24, bottom: 24),
                          child: Divider(
                            color: Colors.grey.shade200,
                            height: 2,
                          ),
                        ),

                        Skeletonizer(
                          enabled: viewModel.isLoading,
                          containersColor: Colors.grey.shade200,
                          effect: ShimmerEffect(
                            baseColor: Colors.grey.shade200,
                            highlightColor: Colors.grey.shade100,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (viewModel.isLoading ||
                                  viewModel.freeDeliveryAvailable)
                                Padding(
                                  padding: EdgeInsetsGeometry.only(bottom: 16),
                                  child:
                                      viewModel.subtotal?.remainingAmount !=
                                                  null &&
                                              viewModel
                                                      .subtotal!
                                                      .remainingAmount! >
                                                  0
                                          ? RichText(
                                            textAlign: TextAlign.left,
                                            text: TextSpan(
                                              text: 'Falta ',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: getTextColor(context),
                                              ),
                                              children: [
                                                TextSpan(
                                                  text:
                                                      '\$${viewModel.subtotal?.remainingAmount?.toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: getTextColor(
                                                      context,
                                                    ),
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      ' para tener envío gratuito',
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: getTextColor(
                                                      context,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                          : Text(
                                            'Conseguiste envío gratis!',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: getTextColor(context),
                                            ),
                                          ),
                                ),
                              if (viewModel.isLoading ||
                                  viewModel.freeDeliveryAvailable)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: viewModel.progress,
                                    backgroundColor: Colors.blue.shade100,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black,
                                    ),
                                    minHeight: 8,
                                  ),
                                ),

                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  RichText(
                                    textAlign: TextAlign.left,
                                    text: TextSpan(
                                      text: 'Subtotal ',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: getTextColor(context),
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              '( ${viewModel.products.length} ${viewModel.products.length == 1 ? 'producto' : 'productos'}):',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: getTextColor(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Text(
                                    viewModel.subtotal?.subtotal != null
                                        ? '\$${viewModel.subtotal?.subtotal?.toStringAsFixed(2)}'
                                        : '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.only(
                      top: 16,
                      left: 20,
                      right: 20,
                    ),
                    child: Row(
                      spacing: 15,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 45,
                            child: CustomButton(
                              label: 'Ver carrito',
                              onPressed:
                                  () => {viewModel.goToShopingCart(context)},
                              type: CustomButtonType.outline,
                              boldText: true,
                            ),
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 45,
                            child: CustomButton(
                              label: 'Ir a checkout',
                              onPressed:
                                  () => {viewModel.goToCheckout(context)},
                              boldText: true,
                            ),
                          ),
                        ),
                      ],
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

