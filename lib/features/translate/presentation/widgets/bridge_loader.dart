import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/native/bridge_native.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class BridgeLoader extends StatefulWidget {
  const BridgeLoader({super.key});
  @override
  State<BridgeLoader> createState() => _BridgeLoaderState();
}

class _BridgeLoaderState extends State<BridgeLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  final Float32List _frame = Float32List(BridgeLayout.total);

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    BridgeNative.instance.frame(_anim.value * 2.6, _frame);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRect(
          child: SizedBox(
            height: 88,
            width: double.infinity,
            child: CustomPaint(painter: _BridgePainter(f: _frame, c: c)),
          ),
        ),
        const SizedBox(height: 8),
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
        const SizedBox(height: 6),
        Text('TERJIME EDILÝÄR', style: AppTheme.label(color: c.sub)),
      ],
    );
  }
}

class _BridgePainter extends CustomPainter {
  final Float32List f;
  final AppColors c;
  _BridgePainter({required this.f, required this.c});

  @override
  void paint(Canvas canvas, Size s) {
    final W = s.width, H = s.height;
    Offset pt(int off, int k) =>
        Offset(f[off + k * 2] * W, f[off + k * 2 + 1] * H);

    final water = Path()..moveTo(0, H);
    for (var k = 0; k < BridgeLayout.wavePts; k++) {
      final p = pt(BridgeLayout.wave1, k);
      water.lineTo(p.dx, p.dy);
    }
    water
      ..lineTo(W, H)
      ..close();
    canvas.drawPath(
      water,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            c.accent.withValues(alpha: 0.16),
            c.accent.withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromLTWH(0, H * 0.78, W, H * 0.22)),
    );

    final w2 = Path()..moveTo(0, pt(BridgeLayout.wave2, 0).dy);
    for (var k = 1; k < BridgeLayout.wavePts; k++) {
      final p = pt(BridgeLayout.wave2, k);
      w2.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      w2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = c.accentHi.withValues(alpha: 0.35),
    );

    for (var k = 0; k < BridgeLayout.hangers; k++) {
      final top = pt(BridgeLayout.hangersOff, k);
      canvas.drawLine(
        top,
        Offset(top.dx, BridgeLayout.deck * H),
        Paint()..color = c.line.withValues(alpha: 0.6)..strokeWidth = 1,
      );
    }

    final cable = Path()..moveTo(f[0] * W, f[1] * H);
    for (var k = 1; k < BridgeLayout.cablePts; k++) {
      final p = pt(BridgeLayout.cable, k);
      cable.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      cable,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..color = c.accent.withValues(alpha: 0.18),
    );
    canvas.drawPath(
      cable,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..color = c.accent,
    );

    for (final tx in [BridgeLayout.x1, BridgeLayout.x2]) {
      final x = tx * W;
      final yTop = BridgeLayout.top * H;
      final yDeck = BridgeLayout.deck * H;
      canvas.drawLine(
        Offset(x, yTop),
        Offset(x, yDeck),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [c.accentHi, c.sub],
          ).createShader(Rect.fromLTRB(x, yTop, x, yDeck)),
      );
      canvas.drawCircle(
        Offset(x, yTop - 4),
        2.2,
        Paint()..color = c.accentHi,
      );
    }

    canvas.drawLine(
      Offset(0.04 * W, BridgeLayout.deck * H),
      Offset(0.96 * W, BridgeLayout.deck * H),
      Paint()..color = c.sub..strokeWidth = 3..strokeCap = StrokeCap.round,
    );

    for (var k = BridgeLayout.trail - 1; k >= 1; k--) {
      final fade = 1 - k / BridgeLayout.trail;
      canvas.drawCircle(
        pt(BridgeLayout.trailOff, k),
        3.5 * fade,
        Paint()..color = c.accentHi.withValues(alpha: 0.35 * fade),
      );
    }

    final dot = pt(BridgeLayout.trailOff, 0);
    canvas.drawCircle(dot, 9, Paint()..color = c.accent.withValues(alpha: 0.25));
    canvas.drawCircle(dot, 4.5, Paint()..color = c.accent);
    canvas.drawCircle(dot, 2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}