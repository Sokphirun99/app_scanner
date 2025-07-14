import 'package:flutter/material.dart';
import 'features/scanner/presentation/scanner_home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Scanner App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ScannerHomePage(),
    );
  }
}
