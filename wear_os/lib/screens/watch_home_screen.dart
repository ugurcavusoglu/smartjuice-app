import 'dart:async';
import 'package:flutter/material.dart';

const Color _kPrimary = Color(0xFFB71C3C);
const Color _kBg = Colors.black;

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
      backgroundColor: _kBg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'V',
              style: TextStyle(
                color: _kPrimary,
                fontSize: 64,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Home (Busy/Ready machine state) ───────────────────────────────────────

class WatchHomeScreen extends StatefulWidget {
  const WatchHomeScreen({super.key});
  @override
  State<WatchHomeScreen> createState() => _WatchHomeScreenState();
}

class _WatchHomeScreenState extends State<WatchHomeScreen> {
  bool _isBusy = true;
  int _countdown = 50;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() { _isBusy = true; _countdown = 50; });
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

  void _goToMenu() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WatchMenuScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          // Clock top-right
          Positioned(
            top: 10, right: 12,
            child: _ClockWidget(),
          ),
          // Main content
          Center(
            child: _isBusy ? _buildBusy() : _buildReady(),
          ),
        ],
      ),
    );
  }

  Widget _buildBusy() {
    return GestureDetector(
      onTap: _goToMenu,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.close, color: _kPrimary, size: 52),
          const SizedBox(height: 8),
          const Text('Busy!',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white38),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _countdownStr,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReady() {
    return GestureDetector(
      onTap: _goToMenu,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, color: Colors.green, size: 64),
          const SizedBox(height: 12),
          const Text('Ready!',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ── Menu screen ───────────────────────────────────────────────────────────

class WatchMenuScreen extends StatelessWidget {
  const WatchMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          Positioned(top: 10, right: 12, child: _ClockWidget()),
          Positioned(
            top: 10, left: 10,
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WatchSettingsScreen()),
              ),
              child: const Icon(Icons.settings, color: Colors.white54, size: 18),
            ),
          ),
          Center(
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
                const SizedBox(height: 10),
                _MenuButton(
                  label: 'Last Recipes',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => WatchRecipeListScreen(
                        title: 'Last Recipes', recipes: _lastRecipes),
                  )),
                ),
                const SizedBox(height: 10),
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
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: _kPrimary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        ),
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
      backgroundColor: _kBg,
      body: Stack(
        children: [
          Positioned(top: 10, right: 12, child: _ClockWidget()),
          Positioned(
            top: 8, left: 8,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(Icons.arrow_back, color: _kPrimary, size: 20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 36, left: 12, right: 12, bottom: 8),
            child: ListView.separated(
              itemCount: recipes.length,
              separatorBuilder: (_, __) => Divider(color: Colors.white12, height: 1),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WatchRecipeDetailScreen(recipe: recipes[i]),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    recipes[i].name,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
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
      backgroundColor: _kBg,
      body: Stack(
        children: [
          Positioned(top: 10, right: 12, child: _ClockWidget()),
          Positioned(
            top: 8, left: 8,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(Icons.arrow_back, color: _kPrimary, size: 20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 36, left: 14, right: 14, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...recipe.ingredients.map((ing) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(ing,
                      style: const TextStyle(color: Colors.white, fontSize: 13)),
                )),
                const Spacer(),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white38),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${recipe.ml} ml',
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
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
  bool _darkMode = true;
  bool _silent = false;
  bool _useOz = false;
  bool _favourite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          Positioned(top: 10, right: 12, child: _ClockWidget()),
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SettingsTile(
                        icon: _darkMode ? Icons.dark_mode : Icons.light_mode,
                        active: _darkMode,
                        onTap: () => setState(() => _darkMode = !_darkMode),
                      ),
                      const SizedBox(width: 14),
                      _SettingsTile(
                        icon: _silent ? Icons.notifications_off : Icons.notifications_off_outlined,
                        active: _silent,
                        onTap: () => setState(() => _silent = !_silent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SettingsTile(
                        label: _useOz ? 'oz' : 'ml',
                        active: true,
                        onTap: () => setState(() => _useOz = !_useOz),
                      ),
                      const SizedBox(width: 14),
                      _SettingsTile(
                        icon: _favourite ? Icons.favorite : Icons.favorite_border,
                        active: _favourite,
                        onTap: () => setState(() => _favourite = !_favourite),
                        activeColor: _favourite ? Colors.red.shade300 : null,
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

  const _SettingsTile({
    this.icon,
    this.label,
    required this.active,
    required this.onTap,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: _kPrimary,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: activeColor ?? Colors.white, size: 26)
              : Text(
                  label!,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}

// ── Clock widget (top-right on every screen) ──────────────────────────────

class _ClockWidget extends StatefulWidget {
  @override
  State<_ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<_ClockWidget> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = _now.hour.toString().padLeft(2, '0');
    final m = _now.minute.toString().padLeft(2, '0');
    return Text(
      '$h:$m',
      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
    );
  }
}
