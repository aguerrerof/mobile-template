import 'package:flutter/material.dart';

class GlobalLoader extends StatelessWidget {
  const GlobalLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Material(
      color: Colors.black45,
      child: Center(
        child: CircularProgressIndicator(color: Colors.grey, strokeWidth: 1.5),
      ),
    );
  }
}
