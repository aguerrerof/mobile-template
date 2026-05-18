import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/services_api.dart';
import 'package:mobile_app_template/components/custom_button.dart';
import 'package:mobile_app_template/components/custom_flushbar.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/loading/loading_viewmodel.dart';
import 'package:provider/provider.dart';

class RecurringUnpaidOrderBanner extends StatelessWidget {
  final int unpaidOrderId;

  const RecurringUnpaidOrderBanner({
    super.key,
    required this.unpaidOrderId,
  });

  Future<void> _openUnpaidOrder(BuildContext context) async {
    if (unpaidOrderId == 0) {
      showCustomFlushbar(
        context,
        message: 'No se encontró la orden pendiente.',
      );
      return;
    }

    final loading = Provider.of<LoadingViewModel>(context, listen: false);
    loading.show();
    try {
      final result =
          await ServicesAPI().getOrderById(unpaidOrderId.toString());
      if (!context.mounted) return;
      if (result.success && result.data != null) {
        Navigator.of(context, rootNavigator: true).pushNamed(
          '/orderDetail',
          arguments: {'order': result.data},
        );
      } else {
        showCustomFlushbar(
          context,
          message: result.getError() ?? 'No se pudo cargar la orden.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        showCustomFlushbar(context, message: getFriendlyErrorMessage(e));
      }
    } finally {
      loading.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade700, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tienes una orden pendiente de pago y necesita tu atención.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: getTextColor(context),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Text(
              'La entrega se realizará 24 horas posterior al pago.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Colors.grey.shade700,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
            label: 'Ver orden',
            onPressed: () => _openUnpaidOrder(context),
            widht: double.infinity,
          ),
        ],
      ),
    );
  }
}

