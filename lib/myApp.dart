import 'package:flutter/material.dart';
import 'homeScreen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(builder: (context) => const HomeScreen());
        },
      ),
    );
  }
}
