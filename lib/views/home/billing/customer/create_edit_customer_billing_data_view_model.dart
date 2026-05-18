import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/services_api.dart';
import 'package:mobile_app_template/components/custom_flushbar.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/loading/loading_viewmodel.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';

enum TypeIdentification {
  cedula('Cédula'),
  ruc('RUC'),
  pasaporte('Pasaporte');

  final String label;
  const TypeIdentification(this.label);
}

TypeIdentification typeIdentificationFromString(String label) {
  return TypeIdentification.values.firstWhere(
    (e) => e.label.toLowerCase() == label.toLowerCase(),
    orElse: () => TypeIdentification.cedula,
  );
}

class CreateOrEditCustomerBillingDataViewModel extends ChangeNotifier {
  bool _isLoading = false;
  CustomerBilling? _customer;
  String _firstName = '';
  String _lastName = '';
  String _identification = '';
  String _phone = '';
  String _email = '';
  String _typeIdentificacion = TypeIdentification.cedula.label;
  bool _isDefault = false;
  List<TypeIdentification> _typesIdentification = [
    TypeIdentification.cedula,
    TypeIdentification.ruc,
    TypeIdentification.pasaporte,
  ];
  TypeIdentification _typeIdentificationSelected = TypeIdentification.cedula;

  bool get isLoading => _isLoading;

  String get firstName => _firstName;
  String get lastName => _lastName;
  String get identification => _identification;
  String get phone => _phone;
  String get email => _email;
  TypeIdentification get typeIdentificationSelected =>
      _typeIdentificationSelected;
  List<TypeIdentification> get typesIdentification => _typesIdentification;

  void updateTypeIdentification(TypeIdentification value) {
    _typeIdentificacion = value.label;
    _typeIdentificationSelected = value;
    notifyListeners();
  }

  void updateCustomer(CustomerBilling customer) {
    _customer = customer;
    updateIdentification(customer.identification ?? '');
    final type = typeIdentificationFromString(customer.type ?? '');
    updateTypeIdentification(type);
    updateFirstName(customer.firstName ?? '');
    updateLastName(customer.lastName ?? '');
    updateEmail(customer.email ?? '');
    updatePhone(customer.phone ?? '');
    updateDefault(customer.isDefault);
    notifyListeners();
  }

  void updateDefault(bool value) {
    _isDefault = value;
    notifyListeners();
  }

  void updateFirstName(String value) {
    _firstName = value;
    notifyListeners();
  }

  void updateLastName(String value) {
    _lastName = value;
    notifyListeners();
  }

  void updateIdentification(String value) {
    _identification = value;
    notifyListeners();
  }

  void updatePhone(String value) {
    _phone = value;
    notifyListeners();
  }

  void updateEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void saveCustomerBilling(
    BuildContext context,
    LoadingViewModel loading,
  ) async {
    FocusScope.of(context).unfocus();
    if (_identification.isEmpty) {
      showCustomFlushbar(context, message: 'Ingrese la identificación');
      return;
    }
    if (_firstName.isEmpty) {
      showCustomFlushbar(context, message: 'Ingrese el nombre.');
      return;
    }
    if (_lastName.isEmpty) {
      showCustomFlushbar(context, message: 'Ingrese el apellido.');
      return;
    }

    if (_phone.isEmpty) {
      showCustomFlushbar(context, message: 'Ingrese el número de teléfono.');
      return;
    }
    if (_email.isEmpty) {
      showCustomFlushbar(context, message: 'Ingrese el email.');
      return;
    }
    loading.show();
    try {
      final customer = CustomerBilling(
        id: _customer?.id,
        identification: _identification,
        firstName: _firstName,
        lastName: _lastName,
        type: _typeIdentificacion,
        phone: _phone,
        email: _email,
        isDefault: _isDefault,
      );

      if (_customer != null) {
        final result = await ServicesAPI().updateCustomerBilling(customer);
        if (result.success) {
          if (context.mounted) {
            Navigator.pop(context);
            showCustomFlushbar(
              context,
              message: result.message ?? 'Se actualizaron los datos',
              backgroundColor: MyColors.successAlertColor,
              textColor: MyColors.successAlerttextColor,
            );
          }
        } else {
          throw Exception(result.getError() ?? 'Error al actualizar los datos');
        }
      } else {
        final response = await ServicesAPI().createBillingInformation(customer);
        if (!response.success) {
          throw Exception(response.getError());
        } else {
          if (context.mounted) {
            Navigator.pop(context);
            showCustomFlushbar(
              context,
              message: 'Datos guardados correctamente.',
              backgroundColor: MyColors.successAlertColor,
              textColor: MyColors.successAlerttextColor,
            );
          }
        }
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

