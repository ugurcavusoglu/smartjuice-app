import 'package:flutter/material.dart';

const _kPrimary = Color(0xFFB71C3C);

class WatchHomeScreen extends StatefulWidget {
  const WatchHomeScreen({super.key});

  @override
  State<WatchHomeScreen> createState() => _WatchHomeScreenState();
}

class _WatchHomeScreenState extends State<WatchHomeScreen> {
  bool _started = false;
  bool _done = false;
  double _progress = 0;

  // Static demo recipe for watch
  final _ingredients = [
    ('Orange', 200),
    ('Mango', 150),
    ('Pineapple', 100),
  ];

  int get _totalMl => _ingredients.fold(0, (s, i) => s + i.$2);

  void _start() {
    setState(() {
      _started = true;
      _progress = 0;
    });
    _animate();
  }

  void _animate() async {
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      setState(() => _progress = i / 10);
    }
    setState(() => _done = true);
  }

  void _reset() => setState(() {
        _started = false;
        _done = false;
        _progress = 0;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _done ? _buildDone() : _started ? _buildMaking() : _buildReady(),
      ),
    );
  }

  Widget _buildReady() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'V',
          style: TextStyle(
            color: _kPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Tropical Energy',
          style: TextStyle(color: Colors.white, fontSize: 11),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        ..._ingredients.map(
          (i) => Text(
            '${i.$1}: ${i.$2}ml',
            style: const TextStyle(color: Colors.grey, fontSize: 9),
          ),
        ),
        Text(
          'Total: ${_totalMl}ml',
          style: const TextStyle(
              color: _kPrimary, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 80,
          height: 28,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: _start,
            child: const Text('Start', style: TextStyle(fontSize: 11)),
          ),
        ),
      ],
    );
  }

  Widget _buildMaking() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            value: _progress,
            color: _kPrimary,
            backgroundColor: Colors.grey.shade800,
            strokeWidth: 6,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(_progress * 100).toInt()}%',
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        const Text('Making...', style: TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  Widget _buildDone() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 40),
        const SizedBox(height: 8),
        const Text('Ready!',
            style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _reset,
          child: const Text('Again',
              style: TextStyle(color: _kPrimary, fontSize: 10)),
        ),
      ],
    );
  }
}
