import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/analitics_service.dart';
import 'package:mobile_app_template/Services/services_api.dart';
import 'package:mobile_app_template/components/benefit_row.dart';
import 'package:mobile_app_template/components/check_card.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:mobile_app_template/components/custom_flushbar.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/utils/local_persistence.dart';
import 'package:mobile_app_template/views/loading/loading_viewmodel.dart';
import 'package:mobile_app_template/components/page_sheet/bottom_page_sheet.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:mobile_app_template/views/topPageSheet/top_page_sheet.dart';
import 'package:provider/provider.dart';
import 'package:singular_flutter_sdk/singular.dart';

class CartProvider extends ChangeNotifier {
  static final CartProvider instance = CartProvider._internal();
  CartProvider._internal();

  factory CartProvider() => instance;

  int _itemCount = 0;
  int get itemCount => _itemCount;

  void addItem() {
    _itemCount++;
    notifyListeners();
  }

  void setCount(int count) {
    _itemCount = count;
    notifyListeners();
  }

  void removeItem() {
    if (_itemCount > 0) {
      _itemCount--;
      notifyListeners();
    }
  }

  void clearCart() {
    _itemCount = 0;
    notifyListeners();
  }
}

String firestoreSafeId(String id) {
  return id.replaceAll('/', '_');
}

Future<void> addToCart({
  required BuildContext context,
  required LoadingViewModel loading,
  required Product product,
  required int count,
  bool? goToConfirmCart,
  bool? showPopup,
  bool? showBottomDetail,
  bool? isRecurrence,
  required bool applyDiscount,
}) async {
  try {
    loading.show();
    final user = FirebaseAuth.instance.currentUser;
    final frequencys = getRecurrenceFrequency();
    final defaultFrequency = frequencys.firstWhere(
      (f) => f.isDefault,
      orElse:
          () => Frequency.fromJson({
            'name': 'Cada 2 semanas',
            'value': 2,
            'isDefault': true,
          }),
    );
    final newItem = {
      'id': 0,
      'title': product.title,
      'price': product.getSelectedVariant()?.price,
      'quantity': count,
      'image_url': product.getOnlyImages().first,
      'variant_id': product.getSelectedVariant()?.id ?? '',
      'flavor': product.getSelectedVariant()?.getFlavorValue() ?? '',
      'size': product.getSelectedVariant()?.getSizeValue() ?? '',
      'apply_tax': product.getSelectedVariant()?.taxable ?? false,
      'is_recurrence': isRecurrence ?? false,
      'frequency': defaultFrequency.name,
      'apply_discount': applyDiscount,
      'available_recurrence': product.isRecurring(),
      'stock':
          product.getSelectedVariant()?.inventoryQuantity ??
          product.getSelectedVariant()?.inventoryItem?.totalStock ??
          0,
    };

    var cartItem = CartItem.fromJson(newItem);
    Singular.event("Add to cart");
    AnalyticsService().trackEvent("Add to cart");
    if (user == null) {
      saveItem(cartItem);
    } else {
      final response = await ServicesAPI().addProductToCart(newItem);
      if (!response.success && response.data != null) {
        throw Exception(response.getError());
      }
      cartItem = response.data!;
    }
    CartProvider.instance.addItem();

    if (showBottomDetail != null && showBottomDetail) {
      final offerRecurrence = await ServicesAPI().getOfferRecurrence(
        product.getSelectedVariant()?.id ?? '',
        count,
      );

      if (context.mounted) {
        CustomBottomSheet.show(
          context: context,
          title: '¡Agregado al carrito!',
          initialChildSize: 0.9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      product.getOnlyImages().first,
                      fit: BoxFit.contain,
                      width: 60,
                      height: 80,
                      loadingBuilder: (context, child, loadingProgress) {
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
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            color: getTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Estas obteniendo el producto por:',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            color: getTextColor(context),
                          ),
                        ),
                        Text(
                          '\$${product.getSelectedVariant()?.price ?? ''}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 24,
                            fontFamily: 'Poppins',
                            color: getTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              CheckCardWidget(
                tapGesture: () => {},
                checked: true,
                backgroundColor: Colors.transparent,
                borderColor: MyColors.checkColor,
                showCheck: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 5,
                  children: [
                    const Text(
                      'Elige Compra Recurrente y paga:',
                      style: TextStyle(
                        color: Colors.green,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      spacing: 5,
                      children: [
                        Text(
                          '\$${offerRecurrence.data?.initialSubtotal}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 24,
                            color: Colors.pink.shade700,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 3),
                          child: Text(
                            'en esta orden',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Colors.pink.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    Text(
                      'Ahorra ${double.parse(offerRecurrence.data?.initialDiscountValue ?? '0.0').toInt()}% en tu primera compra recurrente!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.pink.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '\$${offerRecurrence.data?.subtotal} ',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: getTextColor(context),
                            ),
                          ),
                          TextSpan(
                            text: '(${offerRecurrence.data?.discountValue}%) ',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              color: getTextColor(context),
                            ),
                          ),
                          TextSpan(
                            text: 'ordenes futuras',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              color: getTextColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: Colors.grey.shade200, height: 2),
                    ),

                    // Lista de beneficios
                    BenefitRow(
                      icon: Icon(Icons.savings_outlined, color: Colors.black87),
                      text:
                          'Ahorra ${double.parse(offerRecurrence.data?.discountValue ?? '0.0').toInt()}% en cada orden',
                    ),
                    BenefitRow(
                      icon: Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.black87,
                      ),
                      text: 'Obten entregas personalizadas a tu horario',
                    ),
                    BenefitRow(
                      icon: Icon(Icons.edit_outlined, color: Colors.black87),
                      text: 'Cambia o cancela en cualquier momento.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              CustomButton(
                onPressed: () async {
                  cartItem.isRecurrence = true;
                  cartItem.applyDiscount = true;

                  final loading = Provider.of<LoadingViewModel>(
                    context,
                    listen: false,
                  );
                  loading.show();

                  try {
                    await updateItemCart(cartItem, null);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, '/shopingCart');
                    }
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error actualizando el carrito')),
                    );
                  } finally {
                    loading.hide();
                  }
                },
                label: 'Cambiar a Compra Recurrente',
              ),
              const SizedBox(height: 10),
              CustomButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/shopingCart');
                },
                label: 'Ver Carrito',
                type: CustomButtonType.outline,
              ),
            ],
          ),
        );
      }
      return;
    }
    if (goToConfirmCart != null && goToConfirmCart) {
      if (context.mounted) {
        Navigator.pushNamed(
          context,
          '/ConfirmationAddCard',
          arguments: {'product': product, 'isRecurrence': isRecurrence},
        );
      }
    }
    if (showPopup != null && showPopup) {
      if (context.mounted) {
        TopDownSheet.show(
          context,
          contentBuilder:
              (onClose) => Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 10,
                    children: [
                      Icon(Icons.check, color: Colors.green),
                      Text(
                        '¡Agregado al carrito!',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: getTextColor(context),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: Divider(color: Colors.grey.shade200, height: 2),
                  ),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          product.getOnlyImages().first,
                          fit: BoxFit.contain,
                          width: 60,
                          height: 80,
                          loadingBuilder: (context, child, loadingProgress) {
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
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                color: getTextColor(context),
                              ),
                            ),
                            SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        );
      }
    }
  } catch (e) {
    loading.hide();
    if (context.mounted) {
      showCustomFlushbar(
        context,
        message: 'Se generó un error al agregar el producto al carrito',
      );
    }
  } finally {
    loading.hide();
  }
}

Future<void> removeItem(CartItem item) async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      await deleteItem(item.variantId);
    } else {
      final response = await ServicesAPI().deleteProductCart(item.id);
      if (!response.success) {
        throw Exception(response.getError());
      }
    }
    CartProvider.instance.removeItem();
  } catch (e) {
    print('Error al eliminar productos del carrito: $e');
  }
}

Future<void> clearCart() async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      await deleteCart();
    } else {
      await ServicesAPI().deleteCart();
    }
    CartProvider.instance.clearCart();
  } catch (e) {
    print('Error al eliminar productos del carrito: $e');
  }
}

Future<void> updateItemCart(CartItem item, int? amountChange) async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      await saveItem(item);
      return;
    }

    final response = await ServicesAPI().updateProductCart({
      'id': item.id,
      'quantity': item.quantity,
      'is_recurrence': item.isRecurrence,
      'apply_discount': item.applyDiscount,
      'frequency': item.frequency ?? '',
    });

    if (!response.success) {
      throw Exception(response.getError());
    }
    if (amountChange != null) {
      amountChange > 0
          ? CartProvider.instance.addItem()
          : CartProvider.instance.removeItem();
    }
  } catch (e) {
    print('Error al actualizar productos del carrito: $e');
    rethrow;
  }
}

Future<List<CartItem>> getCartItems() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      final list = getItems();
      int count = 0;
      for (CartItem item in list) {
        count += item.quantity;
      }
      CartProvider.instance.setCount(count);
      return list;
    }

    final response = await ServicesAPI().getShopingCart();
    if (!response.success) {
      throw Exception(response.getError());
    }
    int count = 0;
    for (CartItem item in response.data ?? []) {
      count += item.quantity;
    }
    CartProvider.instance.setCount(count);
    return response.data ?? [];
  } catch (e) {
    print('Error al obtener productos del carrito: $e');
    return [];
  }
}

Future<void> syncLocalCartWithFirestore() async {
  final itemsToSync = getItems();
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    for (var item in itemsToSync) {
      final _ = await ServicesAPI().addProductToCart(item.toCartJson());
    }
    return;
  } catch (e) {
    print('Error al sincronizar productos del carrito: $e');
  }
}

