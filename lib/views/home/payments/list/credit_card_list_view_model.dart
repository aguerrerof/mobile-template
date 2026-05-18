import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/services_api.dart';
import 'package:mobile_app_template/Services/services_api_payment.dart';
import 'package:mobile_app_template/components/custom_flushbar.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/loading/loading_viewmodel.dart';
import 'package:provider/provider.dart';

class CreditCardListViewModel extends ChangeNotifier {
  bool _isLoading = false;
  List<CardDetail> _cards = [];

  List<CardDetail> get cards => _cards;
  bool get isLoading => _isLoading;

  void updateCardList(List<CardDetail> list) {
    _cards = list;
    notifyListeners();
  }

  void fetchUserCards() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ServicesAPI().getCustomerCreditCards();

      print('result customers cards: $result');
      updateCardList(result.data ?? []);
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void deleteCard(BuildContext context, int index) async {
    final loading = Provider.of<LoadingViewModel>(context, listen: false);
    loading.show();

    try {
      final card = _cards[index];
      final result = await ServicesAPIPayment().deleteCard(card.token);

      if (result.success) {
        fetchUserCards();
      } else {
        throw Exception(
          result.getError() != null
              ? result.getError()!
              : 'Error al eliminar la tarjeta',
        );
      }
    } catch (e) {
      print(e);
      if (!context.mounted) return;
      showCustomFlushbar(
        context,
        message: getFriendlyErrorMessage(e),
        duration: 10,
      );
    } finally {
      loading.hide();
    }
  }
}

