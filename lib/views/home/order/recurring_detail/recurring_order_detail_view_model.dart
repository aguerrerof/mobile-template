import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/services_api.dart';
import 'package:mobile_app_template/components/custom_flushbar.dart';
import 'package:mobile_app_template/components/selection_modal_widget.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/utils/local_persistence.dart';
import 'package:mobile_app_template/views/loading/loading_viewmodel.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

class RecurringOrderDetailViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _addressLoading = false;
  // String _userName = '';
  RecurringOrder? _order;
  Address? _addressSelected;
  String? _messageError;
  bool _addressUpdated = false;
  bool _showDeleteDialog = false;
  CardDetail? _card;
  List<Frequency> _frequencies = [];
  Frequency? _frequencySelected;

  bool get isLoading => _isLoading;
  bool get addressLoading => _addressLoading;
  RecurringOrder? get order => _order;
  // String get userName => _userName;
  Address? get addressSelected => _addressSelected;
  String? get messageError => _messageError;
  bool get showDeleteDialog => _showDeleteDialog;
  CardDetail? get card => _card;
  List<Frequency> get frequencies => _frequencies;
  Frequency? get frequencySelected => _frequencySelected;

  void updateAddress(Address address, bool fromList) {
    _addressSelected = address;
    _addressUpdated = fromList;
    notifyListeners();
  }

  void updateMessage(String? message) {
    _messageError = message;
    notifyListeners();
  }

  void updateCard(CardDetail? card) {
    _card = card;
    notifyListeners();
  }

  void updateOrder(RecurringOrder? order) {
    _order = order;
    fetchFrequencies();
    if (order?.shippingAddress != null) {
      updateAddress(order!.shippingAddress!, false);
    }
    if (order?.card != null) {
      updateCard(order!.card);
    }

    notifyListeners();
  }

  void updateDeleteDialogStatus(bool status) {
    _showDeleteDialog = status;
    notifyListeners();
  }

  // Future<void> fetchUser() async {
  //   try {
  //     final currentUser = FirebaseAuth.instance.currentUser;
  //     if (currentUser != null) {
  //       _userName = currentUser.displayName ?? '';
  //       notifyListeners();
  //     }
  //   } catch (e) {
  //     print("Sin usuario: $e");
  //   }
  // }

  Future<void> fetchFrequencies() async {
    _frequencies = getRecurrenceFrequency();
    if (_frequencies.isEmpty) {
      final response = await ServicesAPI().obtainRecurrenceFrequency();
      if (response != null && response.success) {
        _frequencies = response.data ?? [];
      }
    }
    _frequencySelected = _frequencies.firstWhereOrNull(
      (freq) => freq.name == _order!.frequency,
    );
  }

  void deleteItem(BuildContext context, int index) {
    if (_order != null && _order!.lineItems.length > 1) {
      _order?.lineItems.removeAt(index);
      notifyListeners();
    } else {
      updateMessage(
        'No es posible eliminar este artículo: debe permanecer al menos uno en la orden.',
      );
    }
  }

  void showMenuCupertino(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (BuildContext context) => CupertinoActionSheet(
            title: Text('Elija la opción'),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  updateDeleteDialogStatus(true);
                },
                child: Text('Eliminar Orden'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
              },

              isDefaultAction: true,
              child: Text('Cancelar'),
            ),
          ),
    );
  }

  Future<void> changeQuantity(
    CartItem item,
    int delta,
    BuildContext context,
  ) async {
    item.quantity = (item.quantity + delta).clamp(1, 99);
    notifyListeners();
  }

  Future<void> validate(BuildContext context) async {
    if (addressSelected == null) {
      showCustomFlushbar(
        context,
        message:
            'Selecciona una dirección de entrega para continuar con tu pedido.',
      );
      return;
    }

    final loading = Provider.of<LoadingViewModel>(context, listen: false);
    loading.show();
    try {
      final response = await ServicesAPI().updateRecurrenceOrder(
        order!,
        _addressUpdated ? _addressSelected : null,
        _card?.id,
      );

      if (context.mounted) {
        Navigator.pop(context);
        showCustomFlushbar(
          context,
          message:
              response.success
                  ? response.message ?? 'Orden actualizada correctamente'
                  : response.getError() ??
                      'Hubo un error al actualizar la orden',
          backgroundColor:
              response.success ? MyColors.successAlertColor : MyColors.acentOne,
          textColor:
              response.success ? MyColors.successAlerttextColor : Colors.white,
        );
      }
    } catch (e) {
      print(e);
      if (context.mounted) {
        showCustomFlushbar(context, message: getFriendlyErrorMessage(e));
      }
    } finally {
      loading.hide();
    }
  }

  Future<void> deleteOrderRecurrence(BuildContext context) async {
    final loading = Provider.of<LoadingViewModel>(context, listen: false);
    loading.show();
    try {
      final _ = await ServicesAPI().deleteRecurrenceOrder(order?.id ?? 0);
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print(e);
      if (context.mounted) {
        showCustomFlushbar(context, message: getFriendlyErrorMessage(e));
      }
    } finally {
      loading.hide();
    }
  }

  Future<void> showFrecuencyModal(BuildContext context) async {
    final selectedFrequency = Frequency(name: order?.frequency ?? '');
    final result = await showSelectionModal<Frequency>(
      context: context,
      items: _frequencies,
      selectedItem: selectedFrequency,
      itemLabel: (item) => item.name,
      compare: (item1, item2) => item1.name == item2.name,
      title: 'Frecuencias disponibles',
      subtitle: 'Elige la frecuencia de envío que mejor se adapte a tu mascota',
    );

    if (result != null) {
      updateFrecuency(result);
    }
  }

  void updateFrecuency(Frequency? freq) {
    if (freq != null) {
      order?.frequency = freq.name;
      notifyListeners();
    }
  }
}

