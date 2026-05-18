import 'package:flutter/material.dart';

class CategoryCellRectangle extends StatelessWidget {
  final String? imageUrl;
  final String label;
  final String description;
  final TextStyle textStyle;

  const CategoryCellRectangle({
    super.key,
    this.imageUrl,
    required this.label,
    this.description = '',
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
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.network(
                imageUrl?.isNotEmpty == true
                    ? imageUrl!
                    : 'assets/images/imagePlaceholder.jpg',
                fit: BoxFit.contain,
                width: imageSize,
                height: imageSize,
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
            ),

            const SizedBox(height: 5),
            Text(label, style: textStyle, textAlign: TextAlign.center),
            const SizedBox(height: 5),
            Text(
              description,
              style: TextStyle(fontFamily: 'Poppins', fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}
