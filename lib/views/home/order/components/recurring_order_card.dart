import 'package:flutter/material.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:flutter_svg/svg.dart';

class RecurringOrderCard extends StatelessWidget {
  final int items;
  final String? errorMessage;
  final String chargeDate;
  final String deliveryDate;
  final String frequency;
  final VoidCallback onTap;
  final bool? hasUnpaidOrder;

  const RecurringOrderCard({
    super.key,
    required this.items,
    this.errorMessage,
    required this.chargeDate,
    required this.deliveryDate,
    required this.frequency,
    required this.onTap,
    this.hasUnpaidOrder = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: MyColors.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: MyColors.btnColor.withAlpha(50),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsetsGeometry.all(5),
                    child: SvgPicture.asset(
                      'assets/icons/package_2.svg',
                      fit: BoxFit.cover,
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        MyColors.btnColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),
                Text(
                  "$items productos",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: getTextColor(context),
                  ),
                ),

                const SizedBox(width: 10),

                if (errorMessage != null && errorMessage!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                const Spacer(),

                const Icon(Icons.chevron_right),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.credit_card, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  "Siguiente cobro:",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(width: 6),
                Text(hasUnpaidOrder == true ? '--' : chargeDate),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  "Próxima entrega:",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(width: 6),
                Text(hasUnpaidOrder == true ? '--' : deliveryDate),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                frequency,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  color: getTextColor(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

