import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/services_api.dart';
import 'package:mobile_app_template/components/custom_flushbar.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/loading/loading_viewmodel.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';

class CustomerBillingDataListViewModel extends ChangeNotifier {
  bool _isLoading = false;
  List<CustomerBilling> _customersBilling = [];

  List<CustomerBilling> get customersBilling => _customersBilling;
  bool get isLoading => _isLoading;

  void fetchCustomersBilling() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ServicesAPI().getBillingInformationList();
      if (!response.success) {
        throw Exception(response.getError());
      }
      _customersBilling = response.data ?? [];
      notifyListeners();
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateCustomerBilling(
    BuildContext context,
    LoadingViewModel loading,
    CustomerBilling data,
    bool setPrincipal,
  ) async {
    loading.show();

    try {
      final newData = data;
      if (setPrincipal) {
        newData.isDefault = true;
      }

      final result = await ServicesAPI().updateCustomerBilling(newData);
      if (result.success) {
        if (context.mounted) {
          Navigator.pop(context);
          showCustomFlushbar(
            context,
            message: result.message ?? 'Se actualizaron los datos',
            backgroundColor: MyColors.successAlertColor,
            textColor: MyColors.successAlerttextColor,
          );
          fetchCustomersBilling();
        }
      } else {
        throw Exception(result.getError() ?? 'Error al actualizar los datos');
      }
    } catch (e) {
      print(e);
    } finally {
      loading.hide();
    }
  }

  void deleteCustomerBilling(
    BuildContext context,
    LoadingViewModel loading,
    CustomerBilling data,
    int index,
  ) async {
    if (data.isDefault) {
      showCustomFlushbar(
        context,
        message: 'No puedes eliminar un dato predeterminado.',
      );
      return;
    }
    loading.show();

    try {
      final result = await ServicesAPI().removeCustomerBilling(data);

      if (result.success) {
        customersBilling.removeAt(index);
        notifyListeners();

        if (context.mounted) {
          showCustomFlushbar(
            context,
            message: result.message ?? 'Se eliminaron los datos',
            backgroundColor: MyColors.successAlertColor,
            textColor: MyColors.successAlerttextColor,
          );
        }
      } else {
        throw Exception(result.getError() ?? 'Error al eliminar los datos');
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
}

