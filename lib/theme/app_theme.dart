import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color kPrimary = Color(0xFFB71C3C);
const Color kPrimaryLight = Color(0xFFD32F5A);
const Color kBgDark = Color(0xFF1A1A1A);
const Color kCardDark = Color(0xFF2A2A2A);
const Color kCardLight = Color(0xFFF5F5F5);

// ── Tap feedback widget ────────────────────────────────────────────────────
// Wraps any widget: press → scale down + haptic, release → scale up.
class TapEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  const TapEffect({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.92,
  });

  @override
  State<TapEffect> createState() => _TapEffectState();
}

class _TapEffectState extends State<TapEffect> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

ThemeData lightTheme() => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimary,
        brightness: Brightness.light,
      ).copyWith(primary: kPrimary, surface: Colors.white),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: kPrimary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
      cardTheme: CardThemeData(
        color: kCardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
    );

ThemeData darkTheme() => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimary,
        brightness: Brightness.dark,
      ).copyWith(primary: kPrimary, surface: kBgDark),
      scaffoldBackgroundColor: kBgDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: kBgDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: kPrimary,
        unselectedItemColor: Colors.grey,
        backgroundColor: kCardDark,
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
      cardTheme: CardThemeData(
        color: kCardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
    );
