import 'package:flutter/material.dart';

class CategoryCell extends StatelessWidget {
  final String? imageUrl;
  final String label;
  final TextStyle textStyle;

  const CategoryCell({
    super.key,
    this.imageUrl,
    required this.label,
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipOval(
              child: Image.network(
                imageUrl?.isNotEmpty == true
                    ? imageUrl!
                    : 'assets/images/imagePlaceholder.jpg',
                fit: BoxFit.cover,
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: textStyle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
