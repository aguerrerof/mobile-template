import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile_app_template/Services/analitics_service.dart';
import 'package:mobile_app_template/Services/services_api.dart';
import 'package:mobile_app_template/Services/services_api_payment.dart';
import 'package:mobile_app_template/components/custom_flushbar.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/utils/card_functions.dart';
import 'package:mobile_app_template/views/loading/loading_viewmodel.dart';
import 'package:mobile_app_template/views/verificationCode/verification_code.dart';

import 'package:provider/provider.dart';

class CreateCardViewModel extends ChangeNotifier {
  bool _addressLoading = false;
  bool _customerLoading = false;
  Address? _addressSelected;
  CustomerBilling? _customer;
  bool _showpopup = false;

  String _cardNumber = '';
  String _cardName = '';
  String _cardDate = '';
  String _cardCVV = '';

  bool get addressLoading => _addressLoading;
  bool get customerLoading => _customerLoading;
  CustomerBilling? get customer => _customer;
  Address? get addressSelected => _addressSelected;
  bool get showpopup => _showpopup;

  void updateShowpopup(bool origin) {
    _showpopup = origin;
    notifyListeners();
  }

  void updateAddress(Address address) {
    _addressSelected = address;
    notifyListeners();
  }

  void updateCustomer(CustomerBilling customer) {
    _customer = customer;
    notifyListeners();
  }

  void updateCardNumber(String value) {
    AnalyticsService().trackEvent('Editing card number - create card');
    _cardNumber = value;
    print(_cardNumber);
    notifyListeners();
  }

  void updateCardName(String value) {
    AnalyticsService().trackEvent('Editing card name - create card');
    _cardName = value;
    notifyListeners();
  }

  void updateCardDate(String value) {
    AnalyticsService().trackEvent('Editing card date - create card');
    _cardDate = value;
    notifyListeners();
  }

  void updateCardCVV(String value) {
    AnalyticsService().trackEvent('Editing card cvv - create card');
    _cardCVV = value;
    notifyListeners();
  }

  void fetchAddresses() async {
    _addressLoading = true;
    notifyListeners();

    try {
      final result = await ServicesAPI().getCustomerAddresses();

      if (result.success) {
        print('result list address: ${result.data}');
        final list = result.data ?? [];
        if (list.isNotEmpty) {
          final defaultAddress = list.firstWhere(
            (address) => address.isDefault,
            orElse: () => list.first,
          );
          updateAddress(defaultAddress);
        }
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
      _addressLoading = false;
      notifyListeners();
    }
  }

  void fetchCustomersBilling() async {
    _customerLoading = true;
    notifyListeners();

    try {
      final response = await ServicesAPI().getBillingInformationList();
      if (!response.success) {
        throw Exception(response.getError());
      }

      final result = response.data ?? [];

      if (result.isNotEmpty) {
        final defaultCustomer = result.firstWhere(
          (customer) => customer.isDefault,
          orElse: () => result.first,
        );
        updateCustomer(defaultCustomer);
      }
    } catch (e) {
      print(e);
    } finally {
      _customerLoading = false;
      notifyListeners();
    }
  }

  Future<void> scanCard(
    BuildContext context,
    TextEditingController controller,
  ) async {
    // var cardDetails = await CardScanner.scanCard(scanOptions: scanOptions);
    // if (cardDetails?.cardNumber != null) {
    //   print('numero de tarjeta detectado: ${cardDetails?.cardNumber}');
    //   final newValue = cardDetails!.cardNumber;
    //   final newText = newValue.replaceAll(RegExp(r'\D'), '');
    //   final formatted = formatCardNumberText(newText);
    //   controller.text = formatted;
    //   updateCardNumber(formatted);
    // }
  }

  void validateAndCreateCardUser(BuildContext context) async {
    final loading = Provider.of<LoadingViewModel>(context, listen: false);
    loading.show();
    try {
      if (_cardNumber.isEmpty) {
        showCustomFlushbar(context, message: 'Ingrese el número de la tarjeta');
        return;
      }
      if (!isValidCreditCard(_cardNumber)) {
        showCustomFlushbar(context, message: 'Número de tarjeta inválida.');
        return;
      }
      if (_cardName.isEmpty) {
        showCustomFlushbar(
          context,
          message: 'Ingrese el nombre del titular de la tarjeta',
        );
        return;
      }
      if (_cardDate.isEmpty) {
        showCustomFlushbar(
          context,
          message: 'Ingrese la fecha de expedición de la tarjeta',
        );
        return;
      }
      if (!isExpiryDateValid(_cardDate)) {
        showCustomFlushbar(
          context,
          message: 'Fecha de expedición de la tarjeta inválida.',
        );
        return;
      }
      if (_cardCVV.isEmpty) {
        showCustomFlushbar(
          context,
          message: 'Ingrese el código CVV de la tarjeta',
        );
        return;
      }
      if (!RegExp(r'^\d{3,4}$').hasMatch(_cardCVV)) {
        showCustomFlushbar(context, message: 'Código CVV inválido');
        return;
      }
      if (_customer == null) {
        showCustomFlushbar(
          context,
          message: 'Ingrese los datos del titular de la tarjeta',
        );
        return;
      }
      if (_addressSelected == null) {
        showCustomFlushbar(
          context,
          message: 'Ingrese la dirección del titular de la tarjeta',
        );
        return;
      }

      List<String> listTemp = addressSelected?.address1?.split(',') ?? [];
      var number = '0';
      if (listTemp.length > 1) {
        number = listTemp[1];
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('Usuario no autenticado');
        return;
      }

      List<String> dateTemp = _cardDate.split('/');
      var expirationYear = '0';
      var expirationMonth = '0';
      if (listTemp.length > 1) {
        expirationMonth = dateTemp[0];
        expirationYear = dateTemp[1];
      }

      final body = {
        "card": {
          "number": _cardNumber.replaceAll(' ', ''),
          "expirationYear": expirationYear.trim(),
          "expirationMonth": expirationMonth.trim(),
          "cvv": _cardCVV.trim(),
        },
        "buyer": {
          "documentNumber": customer?.identification ?? '',
          "firstName": customer?.firstName?.trim() ?? '',
          "lastName": customer?.lastName?.trim() ?? '',
          "phone": customer?.phone?.trim() ?? '',
          "email": customer?.email?.trim() ?? '',
        },
        "shippingAddress": {
          "country": "EC",
          "city": addressSelected?.city?.trim(),
          "street": addressSelected?.address1?.trim(),
          "number": number.trim(),
        },
        // "user_id": user.uid,
      };

      final response = await ServicesAPIPayment().addCardPayment(body);

      if (response.success) {
        final data = response.data as PaymentCardModel;
        switch (data.status) {
          case "VALIDATION_OTP_REQUIRED":
            if (!context.mounted) return;
            Navigator.pushNamed(
              context,
              '/verificationCode',
              arguments: {
                'flow': FlowsCodeVerification.otp,
                'subtitle': data.message,
                'paymentCard': data,
              },
            ).then((onValue) {
              if (onValue is String) {
                updateShowpopup(true);
              }
            });
          case "TRANSACTION_PENDING_3DS_APPROVAL":
            if (data.details?.url == null) return;
            if (!context.mounted) return;
            Navigator.pushNamed(
              context,
              '/validations3DS',
              arguments: {'url': data.details?.url ?? ''},
            ).then((onValue) {
              if (onValue is Map<String, dynamic>) {
                if (!context.mounted) return;
                validate3DS(context, onValue);
              } else if (onValue is String) {
                if (!context.mounted) return;
                showCustomFlushbar(context, message: onValue);
                return;
              }
            });

          default:
        }
      } else {
        if (context.mounted) {
          showCustomFlushbar(
            context,
            message:
                response.getError() ?? 'Ocurrio un error, intentelo más tarde.',
          );
        }
      }
    } catch (e) {
      print(e);
    } finally {
      loading.hide();
    }
  }

  void validate3DS(BuildContext context, Map<String, dynamic> data) async {
    final loading = Provider.of<LoadingViewModel>(context, listen: false);
    loading.show();
    try {
      final response = await ServicesAPIPayment().verifyStep3DS(data);

      if (response.success) {
        AnalyticsService().trackEvent(
          'Register Card Screen - Successful card link 3ds',
        );
        updateShowpopup(true);
      } else {
        AnalyticsService().trackEvent(
          'Register Card Screen - Card link error 3ds',
        );
        if (context.mounted) {
          showCustomFlushbar(
            context,
            message:
                response.getError() ?? 'Ocurrio un error, intentelo más tarde.',
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

