import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scanAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );

    // Simulate QR scan after 3 seconds → go to main
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go('/main');
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEEEEEE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => context.go('/signup'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // QR scanner frame
            SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                children: [
                  // Corner brackets
                  CustomPaint(
                    size: const Size(220, 220),
                    painter: _QrCornerPainter(),
                  ),
                  // Animated scan line
                  AnimatedBuilder(
                    animation: _scanAnim,
                    builder: (_, __) => Positioned(
                      top: 20 + (_scanAnim.value * 160),
                      left: 20,
                      right: 20,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB71C3C).withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFB71C3C).withValues(alpha: 0.3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            const Text(
              'Scan the code',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

class _QrCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    const corner = 30.0;
    const gap = 20.0;

    // Top-left
    canvas.drawLine(Offset(gap, gap + corner), Offset(gap, gap), paint);
    canvas.drawLine(Offset(gap, gap), Offset(gap + corner, gap), paint);

    // Top-right
    canvas.drawLine(
        Offset(size.width - gap - corner, gap),
        Offset(size.width - gap, gap),
        paint);
    canvas.drawLine(
        Offset(size.width - gap, gap),
        Offset(size.width - gap, gap + corner),
        paint);

    // Bottom-left
    canvas.drawLine(
        Offset(gap, size.height - gap - corner),
        Offset(gap, size.height - gap),
        paint);
    canvas.drawLine(
        Offset(gap, size.height - gap),
        Offset(gap + corner, size.height - gap),
        paint);

    // Bottom-right
    canvas.drawLine(
        Offset(size.width - gap - corner, size.height - gap),
        Offset(size.width - gap, size.height - gap),
        paint);
    canvas.drawLine(
        Offset(size.width - gap, size.height - gap - corner),
        Offset(size.width - gap, size.height - gap),
        paint);
  }

  @override
  bool shouldRepaint(_QrCornerPainter old) => false;
}
