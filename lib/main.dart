import 'package:flutter/material.dart';
import 'screens/localization_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ITantraApp());
}

class ITantraApp extends StatelessWidget {
  const ITantraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iTantra Transceiver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0C0E12),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2F80ED),
          surface: Color(0xFF161A22),
        ),
      ),
      home: const LocalizationScreen(),
    );
  }
}