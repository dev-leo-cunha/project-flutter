import 'package:flutter/material.dart';
import 'package:projeto/styles.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onOpenCamera;
  final VoidCallback onViewHistory;

  const HomePage(
      {super.key, required this.onOpenCamera, required this.onViewHistory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Bem-vindo ao Orbis Geo',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onOpenCamera,
              style: CustomStyles.defaultButtonStyle,
              child: const Text('Abrir Câmera'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onViewHistory,
              style: CustomStyles.defaultButtonStyle,
              child: const Text('Registros'),
            ),
          ],
        ),
      ),
    );
  }
}
