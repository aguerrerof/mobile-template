import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/services_api.dart';
import 'package:mobile_app_template/components/custom_flushbar.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/views/loading/loading_viewmodel.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';

class AddressListViewModel extends ChangeNotifier {
  bool _isLoading = false;
  List<Address> _addresses = [];

  List<Address> get addresses => _addresses;
  bool get isLoading => _isLoading;

  void fetchAddresses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ServicesAPI().getCustomerAddresses();

      if (result.success) {
        _addresses = result.data ?? [];
        notifyListeners();
      } else {
        throw Exception(
          result.errors.isNotEmpty
              ? 'Error message: ${result.errors[0].message}'
              : 'Error al guardar la dirección',
        );
      }
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateAddress(
    BuildContext context,
    LoadingViewModel loading,
    Address address,
    bool setPrincipal,
  ) async {
    loading.show();

    try {
      final newAddres = address;
      if (setPrincipal) {
        newAddres.isDefault = true;
      }

      final result = await ServicesAPI().updateAddress(newAddres);

      if (result.success) {
        print('result update address: ${result.data}');

        if (context.mounted) {
          showCustomFlushbar(
            context,
            message: 'Se actualizó la dirección',
            backgroundColor: MyColors.successAlertColor,
            textColor: MyColors.successAlerttextColor,
          );
        }
        fetchAddresses();
      } else {
        throw Exception(
          result.errors.isNotEmpty
              ? 'Error message: ${result.errors[0].message}'
              : 'Error al actualizar la dirección',
        );
      }
    } catch (e) {
      print(e);
    } finally {
      loading.hide();
    }
  }

  void deleteAddress(
    BuildContext context,
    LoadingViewModel loading,
    Address address,
    int index,
  ) async {
    if (address.isDefault) {
      showCustomFlushbar(
        context,
        message: 'No puedes eliminar una dirección predeterminada.',
      );
      return;
    }
    loading.show();

    try {
      final result = await ServicesAPI().deleteAddress(address.id ?? '');

      if (result.success) {
        addresses.removeAt(index);
        notifyListeners();

        if (context.mounted) {
          showCustomFlushbar(
            context,
            message: result.message ?? 'La dirección se eliminó correctamente.',
            backgroundColor: MyColors.successAlertColor,
            textColor: MyColors.successAlerttextColor,
          );
        }
      } else {
        if (context.mounted) {
          showCustomFlushbar(
            context,
            message: result.getError() ?? 'No se pudo eliminar la dirección.',
          );
        }
      }
    } catch (e) {
      print(e);
    } finally {
      loading.hide();
    }
  }
}

