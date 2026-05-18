import 'package:flutter/cupertino.dart';
import 'package:mobile_app_template/Services/analitics_service.dart';
import 'package:mobile_app_template/Services/services_api_payment.dart';
import 'package:mobile_app_template/components/custom_flushbar.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/views/loading/loading_viewmodel.dart';
import 'package:mobile_app_template/views/verificationCode/verification_code.dart';
import 'package:provider/provider.dart';

class VerificationCodeViewModel extends ChangeNotifier {
  PaymentCardModel? _paymentCardModel;
  FlowsCodeVerification _flow = FlowsCodeVerification.otp;
  String _code = '';
  String? _errorMessage;

  String get code => _code;
  String? get errorMessage => _errorMessage;

  void updatePaymentCardModel(PaymentCardModel data) {
    _paymentCardModel = data;
    notifyListeners();
  }

  void updateFlow(FlowsCodeVerification flow) {
    _flow = flow;
    notifyListeners();
  }

  void updateCode(String data) {
    _code = data;
    notifyListeners();
  }

  void updateError(String? value) {
    _errorMessage = value;
    notifyListeners();
  }

  void sendCodeValidatior(BuildContext context) async {
    final loading = Provider.of<LoadingViewModel>(context, listen: false);
    loading.show();
    try {
      updateError(null);
      if (_code.isEmpty) {
        showCustomFlushbar(context, message: 'Ingrese el código de validación');
        return;
      }

      if (_flow == FlowsCodeVerification.otp) {
        final body = {
          "transaction_id": _paymentCardModel?.details?.idTransaction ?? '',
          "otp": _code,
        };

        final response = await ServicesAPIPayment().verifyCodeOtp(body);

        if (response.success) {
          final data = response.data as PaymentCardModel;
          if (!context.mounted) return;
          Navigator.pop(context, data.message);
          AnalyticsService().trackEvent(
            'Register Card Screen - Successful card link otp',
          );
        } else {
          AnalyticsService().trackEvent(
            'Register Card Screen - Card link error otp',
          );
          if (!context.mounted) return;
          showCustomFlushbar(
            context,
            message:
                response.getError() ??
                'No fue posible verificar el código ingresado',
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

