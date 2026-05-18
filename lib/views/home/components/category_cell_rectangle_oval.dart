import 'dart:ffi';

import 'package:flutter/material.dart';

class CategoryCellRectangleOval extends StatelessWidget {
  final String? imageUrl;
  final String label;
  final TextStyle textStyle;
  final double imageHeight;

  const CategoryCellRectangleOval({
    super.key,
    this.imageUrl,
    required this.label,
    this.imageHeight = 95,
    this.textStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      fontFamily: 'Poppins',
    ),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double imageSize = constraints.maxWidth;
        return SizedBox(
          height: constraints.maxWidth,
          child: Stack(
            children: [
              Column(
                children: [
                  Spacer(),
                  Container(
                    height: constraints.maxWidth * 0.95,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ],
              ),
              // Expanded(
              //   child:
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.network(
                    imageUrl?.isNotEmpty == true
                        ? imageUrl!
                        : 'assets/images/imagePlaceholder.jpg',
                    fit: BoxFit.contain,
                    width: imageSize,
                    // color: Colors.red,
                    height: imageHeight,
                    loadingBuilder: (context, child, loadingProgress) {
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
                          color: Colors.red,
                          child: const Center(
                            child: Text(
                              'Error',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 12),
                      Text(
                        label,
                        style: textStyle,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 15),
                    ],
                  ),
                ],
              ),
              // ),
            ],
          ),
        );
      },
    );
  }
}
