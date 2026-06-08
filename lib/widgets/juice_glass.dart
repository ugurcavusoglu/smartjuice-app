import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class JuiceGlass extends StatelessWidget {
  final double fillFraction;
  final bool isDone;

  const JuiceGlass(
      {super.key, required this.fillFraction, this.isDone = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 240,
      child: CustomPaint(
        painter: _GlassPainter(fillFraction: fillFraction, isDone: isDone),
      ),
    );
  }
}

class _GlassPainter extends CustomPainter {
  final double fillFraction;
  final bool isDone;

  _GlassPainter({required this.fillFraction, required this.isDone});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Flat-bottom cylinder shape (slight taper, straight bottom)
    final tl = Offset(w * 0.12, h * 0.02);
    final tr = Offset(w * 0.88, h * 0.02);
    final br = Offset(w * 0.82, h * 0.95);
    final bl = Offset(w * 0.18, h * 0.95);

    final glassPath = Path()
      ..moveTo(tl.dx, tl.dy)
      ..lineTo(tr.dx, tr.dy)
      ..lineTo(br.dx, br.dy)
      ..lineTo(bl.dx, bl.dy)
      ..close();

    // Fill
    if (fillFraction > 0) {
      final fillColor = isDone
          ? Colors.green.shade400.withValues(alpha: 0.6)
          : kPrimary.withValues(alpha: 0.5);
      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;

      final topY = tl.dy;
      final botY = bl.dy;
      final fillTopY = topY + (botY - topY) * (1 - fillFraction);
      final t = (fillTopY - topY) / (botY - topY);
      final leftX = tl.dx + (bl.dx - tl.dx) * t;
      final rightX = tr.dx + (br.dx - tr.dx) * t;

      final fillPath = Path()
        ..moveTo(leftX, fillTopY)
        ..lineTo(rightX, fillTopY)
        ..lineTo(br.dx, br.dy)
        ..lineTo(bl.dx, bl.dy)
        ..close();

      canvas.save();
      canvas.clipPath(glassPath);
      canvas.drawPath(fillPath, fillPaint);
      canvas.restore();
    }

    // Outline
    final outlinePaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(glassPath, outlinePaint);

    // Straw
    final strawPaint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w * 0.65, -h * 0.04),
      Offset(w * 0.52, h * 0.60),
      strawPaint,
    );

    // Shine line
    final shinePaint = Paint()
      ..color = Colors.black26
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w * 0.23, h * 0.18),
      Offset(w * 0.27, h * 0.55),
      shinePaint,
    );
  }

  @override
  bool shouldRepaint(_GlassPainter old) =>
      old.fillFraction != fillFraction || old.isDone != isDone;
}
