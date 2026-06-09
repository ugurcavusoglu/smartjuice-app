import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart';

const Color _kPrimary = Color(0xFFB71C3C);

// ── Static data ────────────────────────────────────────────────────────────

class _Recipe {
  final String name;
  final List<String> ingredients;
  final int ml;
  _Recipe(this.name, this.ingredients, this.ml);
}

final _favourites = [
  _Recipe('Green Detox', ['1 piece pear', '1 piece cucumber', '5 pieces fresh mint'], 400),
  _Recipe('Cool Garden', ['1 piece apple', '1 piece lemon', '1 piece cucumber'], 350),
  _Recipe('Pink Fresh', ['4 pieces strawberry', '2 slices watermelon'], 200),
  _Recipe('Citrus Blast', ['2 pieces orange', '1 piece grapefruit'], 300),
  _Recipe('Sunrise Glow', ['1 piece mango', '1 piece peach', '1 piece apricot'], 320),
];

final _lastRecipes = [
  _Recipe('Morning Boost', ['1 piece apple', '1 piece ginger', '2 pieces carrot'], 380),
  _Recipe('Tropic Mix', ['1 piece pineapple', '1 piece mango', '1 piece banana'], 420),
  _Recipe('Berry Blast', ['3 pieces strawberry', '1 piece blueberry'], 280),
  _Recipe('Green Power', ['2 pieces spinach', '1 piece cucumber', '1 piece lime'], 350),
];

final _suggestions = [
  _Recipe('Avocado Dream', ['1 piece avocado', '1 piece banana', '1 piece kiwi'], 300),
  _Recipe('Red Energy', ['2 pieces cherry', '1 piece pomegranate'], 250),
  _Recipe('Yellow Sun', ['1 piece pineapple', '1 piece lemon', '1 piece orange'], 400),
  _Recipe('Purple Detox', ['1 piece grape', '1 piece blueberry', '1 piece plum'], 320),
];

// Helper: returns the text/icon color based on theme
Color _fg(BuildContext context) {
  return WatchApp.of(context).isDark ? Colors.white : _kPrimary;
}

Color _fgDim(BuildContext context) {
  return WatchApp.of(context).isDark ? Colors.white54 : _kPrimary.withOpacity(0.6);
}

Color _borderColor(BuildContext context) {
  return WatchApp.of(context).isDark ? Colors.white38 : _kPrimary.withOpacity(0.4);
}

Color _dividerColor(BuildContext context) {
  return WatchApp.of(context).isDark ? Colors.white12 : _kPrimary.withOpacity(0.15);
}

// ── Splash ────────────────────────────────────────────────────────────────

class WatchSplashScreen extends StatefulWidget {
  const WatchSplashScreen({super.key});
  @override
  State<WatchSplashScreen> createState() => _WatchSplashScreenState();
}

class _WatchSplashScreenState extends State<WatchSplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WatchHomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('V',
                style: TextStyle(
                    color: _kPrimary,
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    height: 1)),
            const SizedBox(height: 24),
            SizedBox(
              width: 22, height: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: _fg(context).withOpacity(0.4)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Home (Busy / Ready) ───────────────────────────────────────────────────

class WatchHomeScreen extends StatefulWidget {
  const WatchHomeScreen({super.key});
  @override
  State<WatchHomeScreen> createState() => _WatchHomeScreenState();
}

class _WatchHomeScreenState extends State<WatchHomeScreen> {
  bool _isBusy = true;
  int _countdown = 8;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() { _isBusy = true; _countdown = 8; });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _countdown--);
      if (_countdown <= 0) {
        t.cancel();
        setState(() => _isBusy = false);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _countdownStr {
    final m = _countdown ~/ 60;
    final s = _countdown % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const WatchMenuScreen()),
        ),
        child: Center(
          child: _isBusy ? _buildBusy(context) : _buildReady(context),
        ),
      ),
    );
  }

  Widget _buildBusy(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.close, color: _kPrimary, size: 56),
        const SizedBox(height: 10),
        Text('Busy!',
            style: TextStyle(color: _fg(context), fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: _borderColor(context), width: 1.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(_countdownStr,
              style: TextStyle(
                  color: _fg(context), fontSize: 20, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildReady(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check, color: Colors.green, size: 72),
        const SizedBox(height: 14),
        Text('Ready!',
            style: TextStyle(
                color: _fg(context), fontSize: 26, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ── Menu screen ───────────────────────────────────────────────────────────

class WatchMenuScreen extends StatelessWidget {
  const WatchMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(44, 36, 44, 4),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const WatchSettingsScreen()),
                  ),
                  child: Icon(Icons.settings, color: _fg(context), size: 22),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MenuButton(
                    label: 'Favourites',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => WatchRecipeListScreen(
                          title: 'Favourites', recipes: _favourites),
                    )),
                  ),
                  const SizedBox(height: 8),
                  _MenuButton(
                    label: 'Last Recipes',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => WatchRecipeListScreen(
                          title: 'Last Recipes', recipes: _lastRecipes),
                    )),
                  ),
                  const SizedBox(height: 8),
                  _MenuButton(
                    label: 'Suggestions',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => WatchRecipeListScreen(
                          title: 'Suggestions', recipes: _suggestions),
                    )),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _MenuButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: _kPrimary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ── Recipe list screen ────────────────────────────────────────────────────

class WatchRecipeListScreen extends StatelessWidget {
  final String title;
  final List<_Recipe> recipes;
  const WatchRecipeListScreen({super.key, required this.title, required this.recipes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(44, 36, 44, 6),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.arrow_back, color: _kPrimary, size: 22),
                ),
                const SizedBox(width: 8),
                Text(title,
                    style: TextStyle(color: _fgDim(context), fontSize: 13)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 44),
              itemCount: recipes.length,
              separatorBuilder: (_, __) =>
                  Divider(color: _dividerColor(context), height: 1),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WatchRecipeDetailScreen(recipe: recipes[i]),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(recipes[i].name,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _fg(context), fontSize: 15)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Recipe detail screen ──────────────────────────────────────────────────

class WatchRecipeDetailScreen extends StatelessWidget {
  final _Recipe recipe;
  const WatchRecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(44, 36, 44, 6),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.arrow_back, color: _kPrimary, size: 22),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 44),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: recipe.ingredients
                            .map((ing) => Padding(
                                  padding: const EdgeInsets.only(bottom: 7),
                                  child: Text(ing,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: _fg(context), fontSize: 14)),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
                    decoration: BoxDecoration(
                      border: Border.all(color: _borderColor(context), width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${recipe.ml} ml',
                        style: TextStyle(
                            color: _fg(context),
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Settings screen ───────────────────────────────────────────────────────

class WatchSettingsScreen extends StatefulWidget {
  const WatchSettingsScreen({super.key});
  @override
  State<WatchSettingsScreen> createState() => _WatchSettingsScreenState();
}

class _WatchSettingsScreenState extends State<WatchSettingsScreen> {
  bool _silent = false;
  bool _useOz = false;
  bool _favourite = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final tileSize = size.width * 0.25;
    final gap = size.width * 0.06;
    final appState = WatchApp.of(context);
    final isDark = appState.isDark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(44, 36, 20, 6),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.arrow_back, color: _kPrimary, size: 22),
                ),
                const SizedBox(width: 8),
                Text('Settings',
                    style: TextStyle(color: _fgDim(context), fontSize: 13)),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SettingsTile(
                        icon: isDark ? Icons.dark_mode : Icons.light_mode,
                        active: true,
                        tileSize: tileSize,
                        onTap: () => appState.toggleTheme(),
                      ),
                      SizedBox(width: gap),
                      _SettingsTile(
                        icon: _silent
                            ? Icons.notifications_off
                            : Icons.notifications_off_outlined,
                        active: _silent,
                        tileSize: tileSize,
                        onTap: () => setState(() => _silent = !_silent),
                      ),
                    ],
                  ),
                  SizedBox(height: gap),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SettingsTile(
                        label: _useOz ? 'oz' : 'ml',
                        active: true,
                        tileSize: tileSize,
                        onTap: () => setState(() => _useOz = !_useOz),
                      ),
                      SizedBox(width: gap),
                      _SettingsTile(
                        icon: _favourite ? Icons.favorite : Icons.favorite_border,
                        active: _favourite,
                        tileSize: tileSize,
                        activeColor: _favourite ? Colors.red.shade300 : null,
                        onTap: () => setState(() => _favourite = !_favourite),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final bool active;
  final VoidCallback onTap;
  final Color? activeColor;
  final double tileSize;

  const _SettingsTile({
    this.icon,
    this.label,
    required this.active,
    required this.onTap,
    required this.tileSize,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: tileSize,
        height: tileSize,
        decoration: const BoxDecoration(
          color: _kPrimary,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: activeColor ?? Colors.white, size: tileSize * 0.45)
              : Text(
                  label!,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: tileSize * 0.24,
                      fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}
