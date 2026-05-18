import 'package:flutter/material.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';

class _DiagonalStrikePainter extends CustomPainter {
  _DiagonalStrikePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _DiagonalStrikePainter oldDelegate) =>
      oldDelegate.color != color;
}

class WeightPriceCard extends StatelessWidget {
  final String weight;
  final String price;
  final String pricePerLb;
  final bool isSelected;
  final VoidCallback? onTap;
  /// Cantidad en inventario para este tamaño (variante).
  final int stock;
  final bool isOutOfStock;

  const WeightPriceCard({
    super.key,
    required this.weight,
    required this.price,
    required this.pricePerLb,
    this.isSelected = false,
    this.onTap,
    this.stock = 0,
    this.isOutOfStock = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSelected = isSelected && !isOutOfStock;

    return GestureDetector(
      onTap: isOutOfStock ? null : onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 90,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      effectiveSelected
                          ? MyColors.selectedBorderColor
                          : MyColors.borderColor,
                  width: effectiveSelected ? 2.5 : 0.5,
                ),
                borderRadius: BorderRadius.circular(10),
                color:
                    isOutOfStock
                        ? MyColors.unchekedColor.withValues(alpha: 0.85)
                        : effectiveSelected
                        ? MyColors.checkColor
                        : MyColors.unchekedColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (weight != '')
                    Text(
                      weight,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight:
                            effectiveSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                        color:
                            isOutOfStock
                                ? MyColors.unckekTextColor.withValues(
                                  alpha: 0.45,
                                )
                                : effectiveSelected
                                ? MyColors.checkTextColor
                                : MyColors.unckekTextColor,
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        price,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              effectiveSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                          color:
                              isOutOfStock
                                  ? MyColors.unckekTextColor.withValues(
                                    alpha: 0.45,
                                  )
                                  : effectiveSelected
                                  ? MyColors.checkTextColor
                                  : MyColors.unckekTextColor,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  Text(
                    isOutOfStock
                        ? 'Sin stock'
                        : stock == 1
                        ? '1 disponible'
                        : '$stock disponibles',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      color:
                          isOutOfStock
                              ? MyColors.unckekTextColor.withValues(alpha: 0.5)
                              : effectiveSelected
                              ? MyColors.checkTextColor.withValues(alpha: 0.9)
                              : MyColors.unckekTextColor.withValues(alpha: 0.85),
                    ),
                  ),
                  if (pricePerLb != '')
                    Text(
                      pricePerLb,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            effectiveSelected
                                ? MyColors.checkTextColor
                                : MyColors.unckekTextColor,
                        fontFamily: 'Poppins',
                      ),
                    ),
                ],
              ),
            ),
            if (isOutOfStock)
              Positioned.fill(
                child: CustomPaint(
                  painter: _DiagonalStrikePainter(
                    color: Colors.black.withValues(alpha: 0.35),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

