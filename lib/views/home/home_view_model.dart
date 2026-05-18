import 'package:flutter/cupertino.dart';
import 'package:mobile_app_template/Services/analitics_service.dart';
import 'package:mobile_app_template/components/nav_bar_header.dart';
import 'package:mobile_app_template/utils/cart_helper.dart';
import 'package:provider/provider.dart';

class HomeViewModel extends ChangeNotifier {
  int _currentIndex = 0;
  String _titleSelected = "";

  int get currentIndex => _currentIndex;
  String get title => _titleSelected;

  void updateIndex(int index) {
    switch (index) {
      case 0:
        AnalyticsService().trackEvent("User click home");
      case 1:
        AnalyticsService().trackEvent("User click bienestar");
      case 2:
        AnalyticsService().trackEvent("User click pedidos");
      case 3:
        AnalyticsService().trackEvent("User click perfil");
      default:
        print("no disponible");
    }

    _currentIndex = index;
    notifyListeners();
  }

  Future<void> getCart(BuildContext context) async {
    final _ = await getCartItems();
  }
}

