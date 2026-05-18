import 'package:flutter/material.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Página no encontrada')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Lo sentimos, no pudimos encontrar la pantalla solicitada.',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
