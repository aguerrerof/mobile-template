import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:mobile_app_template/models/response_models.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:mobile_app_template/utils/global_functions.dart';

class ProductCell extends StatelessWidget {
  final Product product;
  final VoidCallback? onAddPressed;

  const ProductCell({super.key, required this.product, this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;

        return Container(
          width: width,
          decoration: BoxDecoration(
            color: Colors.transparent,
            // borderRadius: BorderRadius.circular(24),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withAlpha(100),
            //     blurRadius: 8,
            //     offset: const Offset(0, 4),
            //   ),
            // ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Imagen
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsetsGeometry.all(10),
                            child: Image.network(
                              (product.getSelectedVariant()?.image != null &&
                                      product.getSelectedVariant()?.image != "")
                                  ? product.getSelectedVariant()!.image!
                                  : product.getOnlyImages().first,
                              fit: BoxFit.contain,
                              width: width * 0.75,
                              // height: width * 0.8,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.grey,
                                    strokeWidth: 1.5,
                                  ),
                                );
                              },
                              errorBuilder:
                                  (_, __, ___) => Container(
                                    color: Colors.grey.shade300,
                                    child: const Center(
                                      child: Icon(Icons.broken_image),
                                    ),
                                  ),
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: onAddPressed,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: MyColors.acentTwo,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '\$${product.getSelectedVariant()?.price}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: getTextColor(context),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),

                              if (product
                                      .getSelectedVariant()
                                      ?.compareAtPrice !=
                                  null)
                                Text(
                                  '\$${product.getSelectedVariant()?.compareAtPrice}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            '\$${product.getSelectedVariant()?.getPriceRecurrencing()} con Auto compra',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: getTextColor(context),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

