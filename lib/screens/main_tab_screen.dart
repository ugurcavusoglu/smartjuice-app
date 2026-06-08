import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'home/home_screen.dart';
import 'recipes/recipes_tab_screen.dart';
import 'settings/settings_screen.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _index = 1; // start on Home

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      RecipesTabScreen(onGoHome: () => setState(() => _index = 1)),
      const HomeScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        color: kPrimary,
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.local_drink_outlined,
                  activeIcon: Icons.local_drink,
                  index: 0,
                  currentIndex: _index,
                  onTap: (i) => setState(() => _index = i),
                ),
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  index: 1,
                  currentIndex: _index,
                  onTap: (i) => setState(() => _index = i),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person_rounded,
                  index: 2,
                  currentIndex: _index,
                  onTap: (i) => setState(() => _index = i),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap(index);
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: isActive ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Center(
            child: Icon(
              isActive ? activeIcon : icon,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
