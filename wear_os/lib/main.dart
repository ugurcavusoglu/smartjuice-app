import 'package:flutter/material.dart';
import 'screens/watch_home_screen.dart';

void main() {
  runApp(const WatchApp());
}

const Color _kPrimary = Color(0xFFB71C3C);

class WatchApp extends StatefulWidget {
  const WatchApp({super.key});

  static _WatchAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_WatchAppState>()!;

  @override
  State<WatchApp> createState() => _WatchAppState();
}

class _WatchAppState extends State<WatchApp> {
  bool isDark = true;

  void toggleTheme() => setState(() => isDark = !isDark);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartJuice Watch',
      theme: isDark
          ? ThemeData.dark().copyWith(
              scaffoldBackgroundColor: Colors.black,
              colorScheme: const ColorScheme.dark(primary: _kPrimary),
            )
          : ThemeData.light().copyWith(
              scaffoldBackgroundColor: const Color(0xFFF5F5F5),
              colorScheme: const ColorScheme.light(primary: _kPrimary),
            ),
      home: const WatchSplashScreen(),
    );
  }
}
