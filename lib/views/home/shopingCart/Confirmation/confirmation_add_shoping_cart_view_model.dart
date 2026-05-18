import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile_app_template/Services/services_api.dart';
import 'package:mobile_app_template/Services/services_config.dart';
import 'package:mobile_app_template/components/nav_bar_header.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/utils/cart_helper.dart';
import 'package:mobile_app_template/utils/session_helper.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class ConfirmationShopingCartViewModel extends ChangeNotifier {
  bool _isLoading = false;
  List<CartItem> _products = [];
  double _total = 0.0;
  List<Frequency> _frequency = [];
  SubtotalModel? _subtotal;
  bool _freeDeliveryAvailable = false;
  double _progress = 0.0;

  bool get isLoading => _isLoading;
  List<CartItem> get products => _products;
  double get total => _total;
  List<Frequency> get frequencys => _frequency;
  SubtotalModel? get subtotal => _subtotal;
  bool get freeDeliveryAvailable => _freeDeliveryAvailable;
  double get progress => _progress;

  void fetchFreeDeliveryAvailable() async {
    _freeDeliveryAvailable =
        await ServicesConfig().getConfig<bool>('free_delivery_available') ??
        false;
    notifyListeners();
  }

  void updateProducts(List<CartItem> newProducts) {
    _products = newProducts;
    notifyListeners();
  }

  void getMinAmountFreeDelivery() async {
    final data = await ServicesAPI().generateSubtotals(_products);
    _subtotal = data.data;
    final total = _subtotal?.subtotal ?? 0.0;
    final minAmount = _subtotal?.minAmountFreeDelivery ?? 1.0;
    _progress = total / minAmount;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> getCart() async {
    _isLoading = true;
    notifyListeners();

    final cartItems = await getCartItems();
    updateProducts(cartItems);
    fetchFreeDeliveryAvailable();
    getMinAmountFreeDelivery();
    notifyListeners();
  }

  void goToShopingCart(BuildContext context) {
    Navigator.pushNamed(context, '/shopingCart');
  }

  void goToCheckout(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
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

