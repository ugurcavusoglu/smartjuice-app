import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';
import 'dart:math';
import 'dart:async';
import '../../providers/recipe_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/juice_glass.dart';
import '../../models/ingredient.dart';

const _fruits = [
  ('Apple',      'assets/fruits/apple.svg'),
  ('Banana',     'assets/fruits/banana.svg'),
  ('Orange',     'assets/fruits/orange.svg'),
  ('Pear',       'assets/fruits/pear.svg'),
  ('Peach',      'assets/fruits/peach.svg'),
  ('Cherry',     'assets/fruits/cherry.svg'),
  ('Strawberry', 'assets/fruits/strawberry.svg'),
  ('Blueberry',  'assets/fruits/blueberry.svg'),
  ('Grape',      'assets/fruits/grape.svg'),
  ('Watermelon', 'assets/fruits/watermelon.svg'),
  ('Melon',      'assets/fruits/melon.svg'),
  ('Pineapple',  'assets/fruits/pineapple.svg'),
  ('Mango',      'assets/fruits/mango.svg'),
  ('Kiwi',       'assets/fruits/kiwi.svg'),
  ('Lemon',      'assets/fruits/lemon.svg'),
  ('Coconut',    'assets/fruits/coconut.svg'),
  ('Avocado',    'assets/fruits/avocado.svg'),
  ('Grapefruit', 'assets/fruits/grapefruit.svg'),
];

// Vitamin scores per fruit (0.0 – 1.0), only notable values listed
const _vitaminData = {
  'Melon':      {'A': 0.90},
  'Mango':      {'A': 0.85},
  'Watermelon': {'A': 0.70},
  'Peach':      {'A': 0.40},
  'Grape':      {'A': 0.20, 'C': 0.30, 'K': 0.70},
  'Avocado':    {'B': 0.90, 'E': 0.95, 'K': 0.90},
  'Banana':     {'B': 0.70},
  'Kiwi':       {'B': 0.45, 'C': 0.95, 'K': 0.80},
  'Apple':      {'B': 0.25},
  'Pear':       {'B': 0.20},
  'Orange':     {'B': 0.35, 'C': 0.85},
  'Lemon':      {'B': 0.30, 'C': 0.80},
  'Grapefruit': {'B': 0.35, 'C': 0.90},
  'Pineapple':  {'B': 0.30, 'C': 0.70},
  'Strawberry': {'C': 0.92, 'E': 0.30},
  'Cherry':     {'C': 0.55},
  'Blueberry':  {'C': 0.45, 'E': 0.80, 'K': 0.75},
  'Coconut':    {'B': 0.40},
};

// Calculate vitamin levels from selected fruit names (0.0–1.0, capped at 1.0)
Map<String, double> _calcVitamins(List<String> names) {
  final totals = <String, double>{'A': 0, 'B': 0, 'C': 0, 'E': 0, 'K': 0};
  for (final name in names) {
    final data = _vitaminData[name] ?? {};
    data.forEach((k, v) => totals[k] = (totals[k]! + v).clamp(0.0, 1.0));
  }
  return totals;
}

const _fruitEmojis = {
  'Apple': '🍎', 'Banana': '🍌', 'Orange': '🍊', 'Pear': '🍐',
  'Peach': '🍑', 'Cherry': '🍒', 'Strawberry': '🍓', 'Blueberry': '🫐',
  'Grape': '🍇', 'Watermelon': '🍉', 'Melon': '🍈', 'Pineapple': '🍍',
  'Mango': '🥭', 'Kiwi': '🥝', 'Lemon': '🍋', 'Coconut': '🥥',
  'Avocado': '🥑', 'Grapefruit': '🍊',
};

String _emojiFor(String name) => _fruitEmojis[name] ?? '🍹';

// ── BT status ─────────────────────────────────────────────────────────────

enum _BtStatus { idle, inUse, ready, estimating, juiceReady }

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeProvider>(
      builder: (context, provider, _) {
        const maxMl = 500.0;
        final fill = (provider.totalSelectedMl / maxMl).clamp(0.0, 1.0);
        return _HomeMainView(provider: provider, fill: fill);
      },
    );
  }
}

// ── Main view ─────────────────────────────────────────────────────────────

class _HomeMainView extends StatefulWidget {
  final RecipeProvider provider;
  final double fill;
  const _HomeMainView({required this.provider, required this.fill});

  @override
  State<_HomeMainView> createState() => _HomeMainViewState();
}

class _HomeMainViewState extends State<_HomeMainView>
    with SingleTickerProviderStateMixin {
  List<_PhysicsFruit> _physicsFruits = [];
  int _physicsKey = 0; // force rebuild of physics layer on new batch
  Map<String, double> _vitaminLevels = {};

  // Juice making state
  bool _isMaking = false;       // currently filling
  bool _juiceReady = false;     // fill complete
  int _estimatedSeconds = 0;    // shown in AppBar

  // Glass fill animation
  late AnimationController _fillCtrl;
  late Animation<double> _fillAnim;
  // BT status cycling (only when connected)
  _BtStatus _btStatus = _BtStatus.idle;
  final List<Timer> _btTimers = [];

  @override
  void initState() {
    super.initState();
    _fillCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fillAnim = Tween<double>(begin: 0, end: 0).animate(_fillCtrl);
  }

  @override
  void didUpdateWidget(_HomeMainView old) {
    super.didUpdateWidget(old);
    if (widget.provider.pendingConfirm) {
      widget.provider.consumePendingConfirm();
      final names = widget.provider.selectedIngredients.map((i) => i.name).toList();
      if (names.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _onConfirmIngredients(names);
        });
      }
    }
  }

  @override
  void dispose() {
    _fillCtrl.dispose();
    for (final t in _btTimers) {
      t.cancel();
    }
    super.dispose();
  }

  void _animateFillTo(double target, {VoidCallback? onDone}) {
    final current = _fillAnim.value;
    _fillCtrl.duration = const Duration(milliseconds: 3000);
    _fillAnim = Tween<double>(begin: current, end: target).animate(
      CurvedAnimation(parent: _fillCtrl, curve: Curves.easeInOut),
    );
    _fillCtrl
      ..reset()
      ..forward().whenComplete(() {
        if (mounted) onDone?.call();
      });
  }

  void _startBtCycle() {
    for (final t in _btTimers) {
      t.cancel();
    }
    _btTimers.clear();
    setState(() => _btStatus = _BtStatus.idle);

    final steps = [
      (2000, _BtStatus.inUse),
      (5000, _BtStatus.ready),
      (9000, _BtStatus.estimating),
      (13000, _BtStatus.juiceReady),
      (17000, _BtStatus.idle),
    ];
    for (final s in steps) {
      _btTimers.add(Timer(Duration(milliseconds: s.$1), () {
        if (mounted) setState(() => _btStatus = s.$2);
      }));
    }
  }

  void _stopBtCycle() {
    for (final t in _btTimers) {
      t.cancel();
    }
    _btTimers.clear();
    setState(() => _btStatus = _BtStatus.idle);
  }

  void _openPopup() {
    if (_isMaking) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Currently in use — please wait.'),
          duration: Duration(seconds: 2),
          backgroundColor: kPrimary,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: widget.provider,
        child: _IngredientPopup(
          onConfirm: (names) => _onConfirmIngredients(names),
        ),
      ),
    );
  }

  void _onConfirmIngredients(List<String> names) {
    if (names.isEmpty) return;
    final rng = Random();

    // Compute estimated time: ~8s per fruit, min 10s
    final estSec = (names.length * 8).clamp(10, 120);
    final vitamins = _calcVitamins(names);

    // Build physics fruit list — staggered activation via timers
    final fruits = <_PhysicsFruit>[];
    for (int i = 0; i < names.length; i++) {
      final leftAtTop = _glassLeftX(300, _glassTop) + _fruitRadius;
      final rightAtTop = _glassRightX(300, _glassTop) - _fruitRadius;
      final startX = leftAtTop + rng.nextDouble() * (rightAtTop - leftAtTop);
      final f = _PhysicsFruit(
        emoji: _emojiFor(names[i]),
        x: startX,
        y: _glassTop - _fruitRadius - 10,
        vx: (rng.nextDouble() - 0.5) * 0.25,
        vy: 0.04,
        omega: (rng.nextDouble() - 0.5) * 0.005,
      );
      fruits.add(f);
    }

    setState(() {
      _isMaking = true;
      _juiceReady = false;
      _estimatedSeconds = estSec;
      _fillAnim = Tween<double>(begin: 0, end: 0).animate(_fillCtrl);
      _physicsFruits = fruits;
      _physicsKey++;
    });

    // Activate each fruit with staggered delay
    for (int i = 0; i < fruits.length; i++) {
      final f = fruits[i];
      Future.delayed(Duration(milliseconds: i * 180), () {
        if (mounted) setState(() => f.active = true);
      });
    }

    // After fruits fall (2.5s), clear them and start filling
    final fallDuration = 2500 + names.length * 180;
    Future.delayed(Duration(milliseconds: fallDuration), () {
      if (!mounted) return;
      setState(() {
        _physicsFruits = [];
        _vitaminLevels = vitamins;
      });
      const maxMl = 500.0;
      final newFill = (widget.provider.totalSelectedMl / maxMl).clamp(0.0, 1.0);
      _animateFillTo(newFill, onDone: () {
        setState(() {
          _isMaking = false;
          _juiceReady = true;
          _estimatedSeconds = 0;
        });
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) setState(() => _juiceReady = false);
        });
      });
    });
  }

  void _openProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _ProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? kBgDark : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Red AppBar
          Container(
            color: kPrimary,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 20,
              right: 16,
              bottom: 14,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    settings.silent
                        ? '🔇 Hello ${settings.userName.split(' ').first}!'
                        : 'Hello ${settings.userName.split(' ').first}!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TapEffect(
                  onTap: () => _openProfile(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.person_outline,
                        color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // BT status bar
                  _BtStatusBar(
                    status: _btStatus,
                    connected: settings.btConnected,
                    isMaking: _isMaking,
                    juiceReady: _juiceReady,
                    estimatedSeconds: _estimatedSeconds,
                    onTap: () {
                      settings.toggleBluetooth();
                      if (!settings.btConnected) {
                        _startBtCycle();
                      } else {
                        _stopBtCycle();
                      }
                    },
                  ),

                  // Glass + falling animation
                  SizedBox(
                    height: 280,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          bottom: 0,
                          child: AnimatedBuilder(
                            animation: _fillAnim,
                            builder: (_, __) => JuiceGlass(
                              fillFraction: (!_isMaking && !_juiceReady)
                                  ? 0
                                  : _fillAnim.value,
                              isDark: isDark,
                            ),
                          ),
                        ),
                        if (_physicsFruits.isNotEmpty)
                          Positioned.fill(
                            child: _FruitPhysicsLayer(
                              key: ValueKey(_physicsKey),
                              fruits: _physicsFruits,
                              screenW: MediaQuery.of(context).size.width,
                              onAllSettled: () {},
                            ),
                          ),
                      ],
                    ),
                  ),

                  // + button
                  const SizedBox(height: 8),
                  TapEffect(
                    onTap: _openPopup,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: kPrimary.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: kPrimary, size: 28),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Vitamin bars
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        for (final entry in [
                          ('Vitamin A', 'A'),
                          ('Vitamin B', 'B'),
                          ('Vitamin C', 'C'),
                          ('Vitamin E', 'E'),
                          ('Vitamin K', 'K'),
                        ])
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 82,
                                  child: Text(entry.$1,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black87)),
                                ),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween(
                                        begin: 0,
                                        end: _vitaminLevels[entry.$2] ?? 0,
                                      ),
                                      duration: const Duration(milliseconds: 800),
                                      curve: Curves.easeOut,
                                      builder: (_, val, __) =>
                                          LinearProgressIndicator(
                                        value: val,
                                        minHeight: 10,
                                        backgroundColor:
                                            kPrimary.withValues(alpha: 0.18),
                                        valueColor:
                                            const AlwaysStoppedAnimation(kPrimary),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── BT Status Bar ─────────────────────────────────────────────────────────

class _BtStatusBar extends StatelessWidget {
  final _BtStatus status;
  final bool connected;
  final bool isMaking;
  final bool juiceReady;
  final int estimatedSeconds;
  final VoidCallback onTap;

  const _BtStatusBar({
    required this.status,
    required this.connected,
    required this.isMaking,
    required this.juiceReady,
    required this.estimatedSeconds,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine pill message + color
    // Priority: juice making state > BT status
    String? message;
    Color pillColor = kPrimary;

    if (isMaking) {
      message = 'Estimated time to ready: ${estimatedSeconds}s';
      pillColor = kPrimary;
    } else if (juiceReady) {
      message = 'Fruit juice is ready!';
      pillColor = Colors.green.shade600;
    } else if (!connected) {
      message = null; // no pill when not connected
    } else {
      switch (status) {
        case _BtStatus.idle:
          message = null;
          break;
        case _BtStatus.inUse:
          message = 'Device is currently in use.';
          pillColor = kPrimary;
          break;
        case _BtStatus.ready:
          message = 'The device is ready to use.';
          pillColor = Colors.green.shade600;
          break;
        case _BtStatus.estimating:
          message = 'Estimated time to ready: 5 min';
          pillColor = kPrimary;
          break;
        case _BtStatus.juiceReady:
          message = 'Fruit juice is ready!';
          pillColor = Colors.green.shade600;
          break;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 12, left: 16),
      child: Row(
        children: [
          // Pill — expands to fill available space when visible
          Expanded(
            child: message != null
                ? AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: pillColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      message,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          if (message != null) const SizedBox(width: 10),
          // BT badge (always right-aligned)
          TapEffect(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: connected ? kPrimary : Colors.grey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    connected ? Icons.check : Icons.close,
                    color: connected ? Colors.green.shade300 : Colors.white54,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.bluetooth, color: Colors.white, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile Page ──────────────────────────────────────────────────────────

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? kBgDark : Colors.white,
      body: Column(
        children: [
          Container(
            color: kPrimary,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              right: 16,
              bottom: 14,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Expanded(
                  child: Text('Profile',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Avatar
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: kPrimary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: kPrimary, width: 2.5),
                    ),
                    child: const Center(
                      child: Text('E',
                          style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: kPrimary)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Ela Demir',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('ela@example.com',
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey.shade500)),
                  const SizedBox(height: 32),
                  // Stats row
                  Row(
                    children: [
                      _StatCard(label: 'Recipes', value: '12'),
                      const SizedBox(width: 12),
                      _StatCard(label: 'Favourites', value: '4'),
                      const SizedBox(width: 12),
                      _StatCard(label: 'This Week', value: '7'),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // Info tiles
                  _InfoTile(icon: Icons.person_outline, label: 'Full Name', value: 'Ela Demir'),
                  _InfoTile(icon: Icons.email_outlined, label: 'E-Mail', value: 'ela@example.com'),
                  _InfoTile(icon: Icons.cake_outlined, label: 'Birthday', value: '12 March 1998'),
                  _InfoTile(icon: Icons.location_on_outlined, label: 'Location', value: 'Istanbul, Turkey'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: kPrimary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: kPrimary)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? kCardDark : const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: kPrimary, size: 20),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Physics simulation (parent-managed, supports inter-fruit collision) ───────

const double _glassContainerH = 280;
const double _glassH = 240;
const double _glassW = 180;
const double _glassTop = _glassContainerH - _glassH;
const double _fruitRadius = 26.0; // collision radius (half of 52px emoji)
const double _fruitFontSize = 52.0;

double _glassLeftX(double screenW, double y) {
  final relY = ((y - _glassTop) / _glassH).clamp(0.0, 1.0);
  final glassStartX = (screenW - _glassW) / 2;
  return glassStartX + _glassW * (0.12 + 0.06 * relY);
}

double _glassRightX(double screenW, double y) {
  final relY = ((y - _glassTop) / _glassH).clamp(0.0, 1.0);
  final glassStartX = (screenW - _glassW) / 2;
  return glassStartX + _glassW * (0.88 - 0.06 * relY);
}

double _glassBottomY() => _glassTop + _glassH * 0.95;

class _PhysicsFruit {
  final String emoji;
  double x, y;       // center position in container pixels
  double vx, vy;
  double angle, omega;
  bool active;       // false = waiting for delay
  bool settled;
  double opacity;
  Duration settleTime;
  Duration lastElapsed;

  _PhysicsFruit({
    required this.emoji,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.omega,
  })  : angle = 0,
        active = false,
        settled = false,
        opacity = 1.0,
        settleTime = Duration.zero,
        lastElapsed = Duration.zero;
}

// Single ticker widget that drives ALL fruits together
class _FruitPhysicsLayer extends StatefulWidget {
  final List<_PhysicsFruit> fruits;
  final double screenW;
  final VoidCallback onAllSettled;

  const _FruitPhysicsLayer({
    super.key,
    required this.fruits,
    required this.screenW,
    required this.onAllSettled,
  });

  @override
  State<_FruitPhysicsLayer> createState() => _FruitPhysicsLayerState();
}

class _FruitPhysicsLayerState extends State<_FruitPhysicsLayer>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  Duration _last = Duration.zero;
  bool _notified = false;

  static const double _gravity = 0.00085;
  static const double _bounce = 0.32;
  static const double _friction = 0.72;
  static const double _diameter = _fruitRadius * 2;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    final dt = (elapsed - _last).inMilliseconds.toDouble().clamp(1.0, 32.0);
    _last = elapsed;

    setState(() {
      for (final f in widget.fruits) {
        if (!f.active) continue;
        if (f.settled) {
          // fade out
          final ms = (elapsed - f.settleTime).inMilliseconds;
          f.opacity = (1.0 - ms / 700.0).clamp(0.0, 1.0);
          continue;
        }
        // Gravity
        f.vy += _gravity * dt;

        // Move
        f.x += f.vx * dt;
        f.y += f.vy * dt;
        f.angle += f.omega * dt;

        final bottomY = _glassBottomY() - _fruitRadius;
        final leftX = _glassLeftX(widget.screenW, f.y) + _fruitRadius;
        final rightX = _glassRightX(widget.screenW, f.y) - _fruitRadius;

        // Floor
        if (f.y >= bottomY) {
          f.y = bottomY;
          f.vy = -f.vy * _bounce;
          f.vx *= _friction;
          f.omega *= _friction;
          if (f.vy.abs() < 0.06 && f.vx.abs() < 0.04) {
            f.vy = 0; f.vx = 0; f.omega = 0;
            f.settled = true;
            f.settleTime = elapsed;
          }
        }

        // Walls
        if (f.x <= leftX) {
          f.x = leftX;
          f.vx = f.vx.abs() * _bounce;
          f.omega = -f.omega * _bounce;
        }
        if (f.x >= rightX) {
          f.x = rightX;
          f.vx = -f.vx.abs() * _bounce;
          f.omega = -f.omega * _bounce;
        }
      }

      // Inter-fruit collision (O(n²), n ≤ ~12 so fine)
      final active = widget.fruits.where((f) => f.active && !f.settled).toList();
      for (int i = 0; i < active.length; i++) {
        for (int j = i + 1; j < active.length; j++) {
          final a = active[i];
          final b = active[j];
          final dx = b.x - a.x;
          final dy = b.y - a.y;
          final dist = sqrt(dx * dx + dy * dy);
          if (dist < _diameter && dist > 0.001) {
            // Overlap correction: push apart
            final overlap = (_diameter - dist) / 2;
            final nx = dx / dist;
            final ny = dy / dist;
            a.x -= nx * overlap;
            a.y -= ny * overlap;
            b.x += nx * overlap;
            b.y += ny * overlap;

            // Velocity exchange along normal
            final dvx = a.vx - b.vx;
            final dvy = a.vy - b.vy;
            final dot = dvx * nx + dvy * ny;
            if (dot > 0) {
              // Only resolve if approaching
              final imp = dot * 0.6; // restitution ~0.6
              a.vx -= imp * nx;
              a.vy -= imp * ny;
              b.vx += imp * nx;
              b.vy += imp * ny;
              // Dampen angular spin on impact
              a.omega *= 0.8;
              b.omega *= 0.8;
            }
          }
        }
      }
    });

    // Notify parent when all fruits are done (settled + faded)
    if (!_notified && widget.fruits.every((f) => f.active && f.settled && f.opacity <= 0)) {
      _notified = true;
      widget.onAllSettled();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: widget.fruits.where((f) => f.active).map((f) {
        return Positioned(
          left: f.x - _fruitRadius,
          top: f.y - _fruitRadius,
          child: Opacity(
            opacity: f.opacity,
            child: Transform.rotate(
              angle: f.angle,
              child: Text(
                f.emoji.isNotEmpty ? f.emoji : '🍹',
                style: const TextStyle(fontSize: _fruitFontSize),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}


// ── Ingredient Popup ──────────────────────────────────────────────────────

class _IngredientPopup extends StatefulWidget {
  final ValueChanged<List<String>> onConfirm;
  const _IngredientPopup({required this.onConfirm});

  @override
  State<_IngredientPopup> createState() => _IngredientPopupState();
}

class _IngredientPopupState extends State<_IngredientPopup> {
  final _searchCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  String _query = '';
  final Map<String, int> _counts = {};

  @override
  void dispose() {
    _searchCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  List<(String, String)> get _filtered {
    if (_query.isEmpty) return _fruits;
    return _fruits
        .where((f) => f.$1.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  int get _totalSelected => _counts.values.fold(0, (a, b) => a + b);

  void _confirm(RecipeProvider provider) {
    final selected = <String>[];
    _counts.forEach((name, count) {
      if (count > 0) {
        for (var i = 0; i < count; i++) {
          provider.addIngredient(
              Ingredient(name: name, icon: Icons.circle, ml: 100));
          selected.add(name);
        }
      }
    });
    if (_nameCtrl.text.trim().isNotEmpty) {
      provider.setRecipeName(_nameCtrl.text.trim());
    }
    Navigator.of(context).pop();
    widget.onConfirm(selected);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: kPrimary.withValues(alpha: 0.35)),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.78),
                decoration: BoxDecoration(
                  color: kPrimary.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(Icons.close,
                                color: Colors.white70, size: 22),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                      child: TextField(
                        controller: _searchCtrl,
                        style: const TextStyle(fontSize: 13),
                        onChanged: (v) => setState(() => _query = v),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: const TextStyle(
                              fontSize: 13, color: Colors.black45),
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          suffixIcon: const Icon(Icons.keyboard_arrow_down,
                              color: Colors.black45, size: 20),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 230,
                          color: Colors.white,
                          child: _FruitPickerList(
                            fruits: _filtered,
                            counts: _counts,
                            onCountChanged: (name, val) =>
                                setState(() => _counts[name] = val),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                      child: Column(
                        children: [
                          TextField(
                            controller: _nameCtrl,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Recipe Name',
                              hintStyle: const TextStyle(
                                  fontSize: 13, color: Colors.black45),
                              filled: true,
                              fillColor: Colors.white,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('How many cups?',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13)),
                              const SizedBox(width: 16),
                              _CounterWidget(
                                count: provider.cups,
                                onInc: () =>
                                    provider.setCups(provider.cups + 1),
                                onDec: () =>
                                    provider.setCups(provider.cups - 1),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: _totalSelected > 0
                                  ? () => _confirm(provider)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _totalSelected > 0
                                    ? Colors.white.withValues(alpha: 0.85)
                                    : Colors.white.withValues(alpha: 0.3),
                                foregroundColor: kPrimary,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(30)),
                                elevation: 0,
                              ),
                              child: const Text('Confirm',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Fruit Picker List ─────────────────────────────────────────────────────

class _FruitPickerList extends StatefulWidget {
  final List<(String, String)> fruits;
  final Map<String, int> counts;
  final void Function(String name, int val) onCountChanged;

  const _FruitPickerList({
    required this.fruits,
    required this.counts,
    required this.onCountChanged,
  });

  @override
  State<_FruitPickerList> createState() => _FruitPickerListState();
}

class _FruitPickerListState extends State<_FruitPickerList> {
  int? _selectedIndex;
  static const double _itemH = 76.0;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: widget.fruits.length,
      separatorBuilder: (_, __) => Divider(
          height: 1, color: Colors.black.withValues(alpha: 0.06)),
      itemBuilder: (_, i) {
        final fruit = widget.fruits[i];
        final count = widget.counts[fruit.$1] ?? 0;
        final isSelected = i == _selectedIndex || count > 0;
        return GestureDetector(
          onTap: () => setState(() =>
              _selectedIndex = _selectedIndex == i ? null : i),
          child: SizedBox(
            height: _itemH,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  SvgPicture.asset(
                    fruit.$2,
                    width: 44,
                    height: 44,
                    colorFilter: const ColorFilter.mode(
                        Colors.black87, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(fruit.$1,
                        style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 16)),
                  ),
                  if (isSelected)
                    _VerticalCounter(
                      count: count,
                      onInc: () =>
                          widget.onCountChanged(fruit.$1, count + 1),
                      onDec: () => widget.onCountChanged(
                          fruit.$1, (count - 1).clamp(0, 99)),
                    )
                  else
                    const SizedBox(width: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Figma-style vertical counter: + top, count middle, - bottom
class _VerticalCounter extends StatelessWidget {
  final int count;
  final VoidCallback onInc;
  final VoidCallback onDec;
  const _VerticalCounter(
      {required this.count, required this.onInc, required this.onDec});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onInc,
          child: Icon(Icons.add, color: kPrimary, size: 22),
        ),
        if (count > 0) ...[
          const SizedBox(height: 2),
          Text('$count',
              style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 2),
        ] else
          const SizedBox(height: 4),
        GestureDetector(
          onTap: onDec,
          child: Icon(Icons.remove,
              color: count > 0 ? kPrimary : Colors.black26, size: 22),
        ),
      ],
    );
  }
}

class _CounterWidget extends StatelessWidget {
  final int count;
  final VoidCallback onInc;
  final VoidCallback onDec;
  const _CounterWidget(
      {required this.count, required this.onInc, required this.onDec});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CircleBtn(icon: Icons.remove, onTap: onDec),
        SizedBox(
          width: 32,
          child: Text(
            '$count',
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15),
          ),
        ),
        _CircleBtn(icon: Icons.add, onTap: onInc),
      ],
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: kPrimary.withValues(alpha: 0.25),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}
