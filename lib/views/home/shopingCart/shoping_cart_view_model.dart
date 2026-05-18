import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile_app_template/Services/services_api.dart';
import 'package:mobile_app_template/components/custom_flushbar.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/utils/cart_helper.dart';
import 'package:mobile_app_template/utils/session_helper.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';

class ShopingCartViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSubtotalLoading = false;
  bool _showDeletedItems = false;
  List<CartItem> _products = [];
  List<CartItem> _deletedItemslist = [];
  List<Frequency> _frequency = [];
  SubtotalModel? _subtotal;
  bool _freeDeliveryAvailable = false;
  double _progress = 0.0;
  double _total = 0.0;
  bool _haveOrders = false;

  bool get isLoading => _isLoading;
  bool get isSubtotalLoading => _isSubtotalLoading;
  List<CartItem> get products => _products;
  double get total => _total;
  SubtotalModel? get subtotal => _subtotal;
  bool get freeDeliveryAvailable => _freeDeliveryAvailable;
  List<Frequency> get frequencys => _frequency;
  double get progress => _progress;
  List<CartItem> get deletedItemslist => _deletedItemslist;
  bool get showDeletedItems => _showDeletedItems;
  bool get haveOrders => _haveOrders;

  void updateProducts(List<CartItem> newProducts) {
    _products = newProducts;
    notifyListeners();
    getMinAmountFreeDelivery();
  }

  void updateShowDeletedItems(bool status) {
    _showDeletedItems = status;
    notifyListeners();
  }

  void getMinAmountFreeDelivery() async {
    _isSubtotalLoading = true;
    notifyListeners();
    final data = await ServicesAPI().generateSubtotals(_products);
    _subtotal = data.data;
    _total = _subtotal?.subtotal ?? 0.0;
    final minAmount = _subtotal?.minAmountFreeDelivery ?? 1.0;
    _progress = total / minAmount;
    _isSubtotalLoading = false;
    notifyListeners();
  }

  Future<void> getCart() async {
    _isLoading = true;
    notifyListeners();
    final cartItems = await getCartItems();
    verifyProducts(cartItems);
  }

  Future<void> getOrders() async {
    final response = await ServicesAPI().getUserOrders(1);
    _haveOrders = response.data?.isNotEmpty ?? false;
    notifyListeners();
  }

  Future<void> verifyProducts(List<CartItem> newProducts) async {
    List<CartItem> toDelete = [];
    List<CartItem> cart = [];
    for (final value in newProducts) {
      if (value.stock == 0) {
        toDelete.add(value);
        removeItem(value);
      } else if (value.stock < value.quantity) {
        final item = value;
        final amount = value.stock - value.quantity;
        item.quantity = value.stock;
        updateItemCart(item, amount);
        cart.add(item);
      } else {
        cart.add(value);
      }
    }

    if (toDelete.isNotEmpty) {
      _deletedItemslist = toDelete;
      notifyListeners();
      updateShowDeletedItems(true);
    }

    updateProducts(cart);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> remove(BuildContext context, int index) async {
    final item = _products[index];

    await removeItem(item);
    if (context.mounted) {
      showCustomFlushbar(
        context,
        message: 'Producto eliminado del carrito.',
        backgroundColor: MyColors.successAlertColor,
        textColor: MyColors.successAlerttextColor,
      );
    }
    getCart();
    notifyListeners();
  }

  Future<void> changeQuantity(int index, int delta) async {
    _products[index].quantity = (_products[index].quantity + delta).clamp(
      1,
      99,
    );
    notifyListeners();
    updateItemCart(_products[index], delta);
    getMinAmountFreeDelivery();
  }

  Future<void> updateRecurrence(int index, bool isRecurrence) async {
    _products[index].isRecurrence = isRecurrence;
    _products[index].applyDiscount = isRecurrence;
    notifyListeners();
    updateItemCart(_products[index], null);
    getMinAmountFreeDelivery();
  }

  void goToProductDetail(BuildContext context, Product product) {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamed('/productDetail', arguments: product);
  }

  void goToCheckout(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('Usuario no autenticado');
      Session.screenPostLoggin = '/checkout';
      Session.screenParent = '/shopingCart';
      Navigator.pushNamed(context, '/login-one');
      return;
    }
    Navigator.pushNamed(context, '/checkout').then((value) {
      getCart();
    });
  }
}

