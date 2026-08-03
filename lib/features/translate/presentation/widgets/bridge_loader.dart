import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

/// Статичный силуэт моста + тихий прогресс-бар. Рисуется ОДИН раз.
class BridgeLoader extends StatelessWidget {
  const BridgeLoader({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 70,
          width: double.infinity,
          child: CustomPaint(painter: _Bridge(c: c)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 160,
          height: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              backgroundColor: c.line,
              valueColor: AlwaysStoppedAnimation(c.accent),
              minHeight: 3,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('TERJIME EDILÝÄR', style: AppTheme.label(color: c.sub)),
      ],
    );
  }
}

class _Bridge extends CustomPainter {
  final AppColors c;
  _Bridge({required this.c});
  @override
  void paint(Canvas canvas, Size s) {
    final W = s.width, H = s.height;
    final deck = H * 0.64, top = H * 0.16, x1 = W * 0.32, x2 = W * 0.68;
    final tower = Paint()
      ..color = c.sub
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x1, top), Offset(x1, deck), tower);
    canvas.drawLine(Offset(x2, top), Offset(x2, deck), tower);
    final sag = Offset(W * 0.5, H * 0.44);
    final cable = Path()
      ..moveTo(W * 0.05, deck - 4)
      ..lineTo(x1, top)
      ..quadraticBezierTo(sag.dx, sag.dy, x2, top)
      ..lineTo(W * 0.95, deck - 4);
    canvas.drawPath(
      cable,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..color = c.accent,
    );
    for (int i = 1; i <= 9; i++) {
      final t = i / 10.0, m = 1 - t;
      final bx = Offset(
        m * m * x1 + 2 * m * t * sag.dx + t * t * x2,
        m * m * top + 2 * m * t * sag.dy + t * t * top,
      );
      canvas.drawLine(
        bx,
        Offset(bx.dx, deck),
        Paint()
          ..color = c.line
          ..strokeWidth = 1,
      );
    }
    canvas.drawLine(
      Offset(W * 0.05, deck),
      Offset(W * 0.95, deck),
      Paint()
        ..color = c.sub
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
