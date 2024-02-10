import 'package:flutter/material.dart';

import 'features/dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fleksa',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
        ),
        bottomAppBarTheme: const BottomAppBarTheme(
          color: Colors.black,
        ),
      ),
      home: const Fleksa(),
    );
  }
}
