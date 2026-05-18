import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  final String name;
  final bool selected;

  const CategoryItem({super.key, required this.name, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: selected ? Colors.blue : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: DefaultTextStyle(
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            // fontSize: 16,
          ),
          child: Text(name),
        ),
      ),
    );
  }
}
