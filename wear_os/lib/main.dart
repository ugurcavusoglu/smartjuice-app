import 'package:flutter/material.dart';
import 'screens/watch_home_screen.dart';

void main() {
  runApp(const WatchApp());
}

class WatchApp extends StatelessWidget {
  const WatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartJuice Watch',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(primary: _kPrimary),
      ),
      home: const WatchSplashScreen(),
    );
  }
}

const Color _kPrimary = Color(0xFFB71C3C);
